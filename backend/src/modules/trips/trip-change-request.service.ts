import {
  Prisma,
  TripChangeRequestStatus,
  TripChangeRequestType,
  TripStatus,
} from "@prisma/client";
import { shouldUseMemoryFallback } from "../../core/config/data-availability.js";
import { HttpError } from "../../core/utils/http-error.js";
import prisma from "../../infrastructure/database/prisma.js";
import { memoryDb } from "../../infrastructure/fallback/memory-db.js";
import type {
  CreateTripChangeRequestInput,
  ReviewTripChangeRequestInput,
} from "./trip-change-request.schema.js";

function assertEligibleTrip(trip: {
  status: TripStatus | "PENDING" | "ONGOING" | "COMPLETED" | "CANCELLED";
  isUpcoming: boolean;
}) {
  const active = trip.status === TripStatus.PENDING || trip.status === TripStatus.ONGOING;
  if (!active || !trip.isUpcoming) {
    throw new HttpError(409, "Only an upcoming active trip can be changed");
  }
}

function requestType(type: CreateTripChangeRequestInput["type"]) {
  return type === "RESCHEDULE"
    ? TripChangeRequestType.RESCHEDULE
    : TripChangeRequestType.REFUND;
}

function isUniquePendingRequestError(error: unknown): boolean {
  return error instanceof Prisma.PrismaClientKnownRequestError && error.code === "P2002";
}

function normalizeAdminNote(note: string | undefined): string | null {
  const normalized = note?.trim();
  return normalized ? normalized : null;
}

function resolveRefundAmount(
  request: {
    type: TripChangeRequestType | "RESCHEDULE" | "REFUND";
    trip: { totalPrice?: Prisma.Decimal | number | null };
  },
  input: ReviewTripChangeRequestInput,
): number | null {
  const approvingRefund =
    input.decision === "APPROVED" && request.type === TripChangeRequestType.REFUND;

  if (!approvingRefund) {
    if (input.refundAmount !== undefined) {
      throw new HttpError(400, "refundAmount is only allowed when approving a refund");
    }
    return null;
  }

  if (input.refundAmount === undefined) {
    throw new HttpError(400, "refundAmount is required when approving a refund");
  }

  const totalPrice = request.trip.totalPrice;
  if (totalPrice !== null && totalPrice !== undefined && input.refundAmount > Number(totalPrice)) {
    throw new HttpError(400, "refundAmount cannot exceed the trip total price");
  }

  return input.refundAmount;
}

export const tripChangeRequestService = {
  async listForAdmin(
    status?: TripChangeRequestStatus | "PENDING" | "APPROVED" | "REJECTED",
  ) {
    if (await shouldUseMemoryFallback()) {
      return memoryDb.tripChangeRequests
        .filter((request) => !status || request.status === status)
        .sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime())
        .flatMap((request) => {
          const trip = memoryDb.findTripById(request.tripId);
          if (!trip) return [];
          const user = trip.userId ? memoryDb.findUserById(trip.userId) : null;
          return [{
            ...request,
            trip: {
              ...trip,
              user: user ? { id: user.id, name: user.name, email: user.email } : null,
            },
          }];
        });
    }

    return prisma.tripChangeRequest.findMany({
      where: status ? { status: status as TripChangeRequestStatus } : {},
      include: {
        trip: {
          include: {
            user: { select: { id: true, name: true, email: true } },
          },
        },
      },
      orderBy: { createdAt: "desc" },
    });
  },

  async listForTrip(userId: string | undefined, tripId: string) {
    if (!userId) throw new HttpError(401, "Authentication required");

    if (await shouldUseMemoryFallback()) {
      const trip = memoryDb.findTripById(tripId);
      if (!trip || trip.userId !== userId) {
        throw new HttpError(404, "Trip not found or unauthorized");
      }
      return memoryDb.findTripChangeRequestsByTripId(tripId);
    }

    const trip = await prisma.trip.findFirst({
      where: { id: tripId, userId },
      select: { id: true },
    });
    if (!trip) throw new HttpError(404, "Trip not found or unauthorized");

    return prisma.tripChangeRequest.findMany({
      where: { tripId },
      orderBy: { createdAt: "desc" },
    });
  },

  async create(
    userId: string | undefined,
    tripId: string,
    input: CreateTripChangeRequestInput,
  ) {
    if (!userId) throw new HttpError(401, "Authentication required");

    if (await shouldUseMemoryFallback()) {
      const trip = memoryDb.findTripById(tripId);
      if (!trip || trip.userId !== userId) {
        throw new HttpError(404, "Trip not found or unauthorized");
      }
      assertEligibleTrip(trip);
      if (memoryDb.findPendingTripChangeRequest(tripId)) {
        throw new HttpError(409, "A change request is already pending for this trip");
      }
      return memoryDb.createTripChangeRequest({
        tripId,
        type: input.type,
        status: "PENDING",
        reason: input.reason,
        requestedDate: input.type === "RESCHEDULE" ? input.requestedDate : null,
        refundAmount: null,
        adminNote: null,
        reviewedAt: null,
      });
    }

    try {
      return await prisma.$transaction(async (tx) => {
        const trip = await tx.trip.findFirst({ where: { id: tripId, userId } });
        if (!trip) throw new HttpError(404, "Trip not found or unauthorized");
        assertEligibleTrip(trip);

        const pending = await tx.tripChangeRequest.findFirst({
          where: { tripId, status: TripChangeRequestStatus.PENDING },
          select: { id: true },
        });
        if (pending) {
          throw new HttpError(409, "A change request is already pending for this trip");
        }

        return tx.tripChangeRequest.create({
          data: {
            tripId,
            type: requestType(input.type),
            status: TripChangeRequestStatus.PENDING,
            reason: input.reason,
            requestedDate: input.type === "RESCHEDULE" ? input.requestedDate : null,
          },
        });
      });
    } catch (error) {
      if (isUniquePendingRequestError(error)) {
        throw new HttpError(409, "A change request is already pending for this trip");
      }
      throw error;
    }
  },

  async review(requestId: string, input: ReviewTripChangeRequestInput) {
    if (await shouldUseMemoryFallback()) {
      const request = memoryDb.findTripChangeRequestById(requestId);
      if (!request) throw new HttpError(404, "Trip change request not found");
      if (request.status !== "PENDING") {
        throw new HttpError(409, "This request has already been reviewed");
      }

      const trip = memoryDb.findTripById(request.tripId);
      if (!trip) throw new HttpError(404, "Trip not found");
      assertEligibleTrip(trip);

      const approved = input.decision === "APPROVED";
      if (approved && request.type === "RESCHEDULE" && !request.requestedDate) {
        throw new HttpError(409, "Reschedule request has no requested date");
      }
      const refundAmount = resolveRefundAmount({ type: request.type, trip }, input);
      const updatedRequest = memoryDb.updateTripChangeRequest(requestId, {
        status: approved ? "APPROVED" : "REJECTED",
        refundAmount,
        adminNote: normalizeAdminNote(input.adminNote),
        reviewedAt: new Date(),
      });
      if (!updatedRequest) throw new HttpError(404, "Trip change request not found");

      let updatedTrip = trip;
      if (approved && request.type === "REFUND") {
        updatedTrip = memoryDb.updateTrip(trip.id, {
          status: "CANCELLED",
          isUpcoming: false,
        }) ?? trip;
      } else if (approved && request.type === "RESCHEDULE") {
        updatedTrip = memoryDb.updateTrip(trip.id, {
          date: request.requestedDate!,
          isUpcoming: true,
        }) ?? trip;
      }

      return { request: updatedRequest, trip: updatedTrip };
    }

    return prisma.$transaction(async (tx) => {
      const existing = await tx.tripChangeRequest.findUnique({
        where: { id: requestId },
        include: { trip: true },
      });
      if (!existing) throw new HttpError(404, "Trip change request not found");
      if (existing.status !== TripChangeRequestStatus.PENDING) {
        throw new HttpError(409, "This request has already been reviewed");
      }
      assertEligibleTrip(existing.trip);

      const refundAmount = resolveRefundAmount(existing, input);
      const approved = input.decision === "APPROVED";
      const claimed = await tx.tripChangeRequest.updateMany({
        where: { id: requestId, status: TripChangeRequestStatus.PENDING },
        data: {
          status: approved
            ? TripChangeRequestStatus.APPROVED
            : TripChangeRequestStatus.REJECTED,
          refundAmount,
          adminNote: normalizeAdminNote(input.adminNote),
          reviewedAt: new Date(),
        },
      });
      if (claimed.count !== 1) {
        throw new HttpError(409, "This request has already been reviewed");
      }

      let trip = existing.trip;
      if (approved && existing.type === TripChangeRequestType.REFUND) {
        trip = await tx.trip.update({
          where: { id: existing.tripId },
          data: { status: TripStatus.CANCELLED, isUpcoming: false },
        });
      } else if (approved && existing.type === TripChangeRequestType.RESCHEDULE) {
        if (!existing.requestedDate) {
          throw new HttpError(409, "Reschedule request has no requested date");
        }
        trip = await tx.trip.update({
          where: { id: existing.tripId },
          data: { date: existing.requestedDate, isUpcoming: true },
        });
      }

      const request = await tx.tripChangeRequest.findUniqueOrThrow({
        where: { id: requestId },
      });
      return { request, trip };
    });
  },
};
