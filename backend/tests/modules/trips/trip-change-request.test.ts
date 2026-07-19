import { Prisma } from "@prisma/client";
import { beforeEach, describe, expect, it, vi } from "vitest";
import {
  createTripChangeRequestSchema,
  reviewTripChangeRequestSchema,
} from "../../../src/modules/trips/trip-change-request.schema.js";
import { memoryDb } from "../../../src/infrastructure/fallback/memory-db.js";

const mocks = vi.hoisted(() => ({
  shouldUseMemoryFallback: vi.fn(),
  transaction: vi.fn(),
  findOwnedTrip: vi.fn(),
  findPendingRequest: vi.fn(),
  createRequest: vi.fn(),
  updateRequest: vi.fn(),
  updateTrip: vi.fn(),
  findRequest: vi.fn(),
  findRequestOrThrow: vi.fn(),
  findAdminRequests: vi.fn(),
  directFindTrip: vi.fn(),
}));

const persistentTransaction = {
  trip: {
    findFirst: mocks.findOwnedTrip,
    update: mocks.updateTrip,
  },
  tripChangeRequest: {
    findFirst: mocks.findPendingRequest,
    findUnique: mocks.findRequest,
    findUniqueOrThrow: mocks.findRequestOrThrow,
    create: mocks.createRequest,
    updateMany: mocks.updateRequest,
  },
};

vi.mock("../../../src/core/config/data-availability.js", () => ({
  shouldUseMemoryFallback: mocks.shouldUseMemoryFallback,
}));

vi.mock("../../../src/infrastructure/database/prisma.js", () => ({
  default: {
    $transaction: mocks.transaction,
    trip: { findFirst: mocks.directFindTrip },
    tripChangeRequest: { findMany: mocks.findAdminRequests },
  },
}));

import { tripChangeRequestService } from "../../../src/modules/trips/trip-change-request.service.js";

describe("trip change request input", () => {
  it("accepts a future reschedule and requires its requested date", () => {
    expect(
      createTripChangeRequestSchema.safeParse({
        type: "RESCHEDULE",
        reason: "Tôi cần chuyển lịch vì có lịch thi.",
        requestedDate: "25/08/2099",
      }).success,
    ).toBe(true);

    expect(
      createTripChangeRequestSchema.safeParse({
        type: "RESCHEDULE",
        reason: "Tôi cần chuyển lịch vì có lịch thi.",
      }).success,
    ).toBe(false);
  });

  it("rejects a requested date for refunds", () => {
    expect(
      createTripChangeRequestSchema.safeParse({
        type: "REFUND",
        reason: "Tôi không thể tham gia chuyến đi này.",
        requestedDate: "25/08/2099",
      }).success,
    ).toBe(false);
  });

  it("rejects an invalid date inside a requested date range", () => {
    expect(
      createTripChangeRequestSchema.safeParse({
        type: "RESCHEDULE",
        reason: "Tôi cần chuyển lịch vì có lịch thi.",
        requestedDate: "25/08/2099 - 31/02/2100",
      }).success,
    ).toBe(false);
  });

  it("accepts an optional non-negative review amount", () => {
    expect(
      reviewTripChangeRequestSchema.safeParse({
        decision: "APPROVED",
        refundAmount: 250000,
      }).success,
    ).toBe(true);
    expect(
      reviewTripChangeRequestSchema.safeParse({ decision: "REJECTED" }).success,
    ).toBe(true);
    expect(
      reviewTripChangeRequestSchema.safeParse({
        decision: "REJECTED",
        refundAmount: -1,
      }).success,
    ).toBe(false);
  });
});

describe("trip change request lifecycle", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mocks.shouldUseMemoryFallback.mockResolvedValue(true);
    memoryDb.trips.length = 0;
    (memoryDb as { tripChangeRequests?: unknown[] }).tripChangeRequests = [];
    memoryDb.trips.push({
      id: "trip-1",
      userId: "user-1",
      destination: "Đà Lạt",
      location: "Lâm Đồng",
      date: "25/08/2099",
      guests: "2",
      status: "ONGOING",
      imagePath: "/uploads/dalat.jpg",
      isUpcoming: true,
      totalPrice: 1000000,
      isCustom: false,
      paymentStatus: "SUCCESS",
      paymentTxnRef: "txn-1",
      createdAt: new Date("2099-01-01T00:00:00.000Z"),
      updatedAt: new Date("2099-01-01T00:00:00.000Z"),
    });
  });

  it("lets an owner create one pending refund request and rejects a duplicate", async () => {
    await expect(
      tripChangeRequestService.create("user-1", "trip-1", {
        type: "REFUND",
        reason: "Tôi không thể tham gia chuyến đi này.",
      }),
    ).resolves.toMatchObject({
      tripId: "trip-1",
      type: "REFUND",
      status: "PENDING",
    });

    await expect(
      tripChangeRequestService.create("user-1", "trip-1", {
        type: "REFUND",
        reason: "Tôi vẫn không thể tham gia chuyến đi này.",
      }),
    ).rejects.toMatchObject({ statusCode: 409 });
  });

  it("returns requests only to the trip owner", async () => {
    await tripChangeRequestService.create("user-1", "trip-1", {
      type: "REFUND",
      reason: "Tôi không thể tham gia chuyến đi này.",
    });

    await expect(
      tripChangeRequestService.listForTrip("user-1", "trip-1"),
    ).resolves.toMatchObject([
      { tripId: "trip-1", status: "PENDING" },
    ]);

    await expect(
      tripChangeRequestService.listForTrip("user-2", "trip-1"),
    ).rejects.toMatchObject({ statusCode: 404 });
  });

  it("approves a refund by cancelling the trip without clearing payment history", async () => {
    const request = await tripChangeRequestService.create("user-1", "trip-1", {
      type: "REFUND",
      reason: "Tôi không thể tham gia chuyến đi này.",
    });

    await expect(
      tripChangeRequestService.review(request.id, {
        decision: "APPROVED",
        refundAmount: 750000,
        adminNote: "Đã duyệt hoàn tiền mô phỏng.",
      }),
    ).resolves.toMatchObject({
      request: {
        status: "APPROVED",
        refundAmount: 750000,
        adminNote: "Đã duyệt hoàn tiền mô phỏng.",
      },
      trip: {
        status: "CANCELLED",
        isUpcoming: false,
        paymentStatus: "SUCCESS",
        paymentTxnRef: "txn-1",
      },
    });
  });

  it("keeps an invalid legacy reschedule request pending when it cannot be applied", async () => {
    const request = memoryDb.createTripChangeRequest({
      tripId: "trip-1",
      type: "RESCHEDULE",
      status: "PENDING",
      reason: "Tôi cần chuyển lịch vì có lịch thi.",
      requestedDate: null,
      refundAmount: null,
      adminNote: null,
      reviewedAt: null,
    });

    await expect(
      tripChangeRequestService.review(request.id, { decision: "APPROVED" }),
    ).rejects.toMatchObject({ statusCode: 409 });

    expect(memoryDb.findTripChangeRequestById(request.id)).toMatchObject({
      status: "PENDING",
    });
  });

  it("approves a reschedule without changing payment or active trip status", async () => {
    const request = await tripChangeRequestService.create("user-1", "trip-1", {
      type: "RESCHEDULE",
      reason: "Tôi cần chuyển lịch vì có lịch thi.",
      requestedDate: "26/08/2099",
    });

    await expect(
      tripChangeRequestService.review(request.id, { decision: "APPROVED" }),
    ).resolves.toMatchObject({
      request: { status: "APPROVED", requestedDate: "26/08/2099" },
      trip: {
        date: "26/08/2099",
        status: "ONGOING",
        isUpcoming: true,
        paymentStatus: "SUCCESS",
      },
    });

    await expect(
      tripChangeRequestService.review(request.id, { decision: "REJECTED" }),
    ).rejects.toMatchObject({ statusCode: 409 });
  });

  it("rejects an over-total refund and lets the admin reject without changing the trip", async () => {
    const request = await tripChangeRequestService.create("user-1", "trip-1", {
      type: "REFUND",
      reason: "Tôi không thể tham gia chuyến đi này.",
    });

    await expect(
      tripChangeRequestService.review(request.id, {
        decision: "APPROVED",
        refundAmount: 1000001,
      }),
    ).rejects.toMatchObject({ statusCode: 400 });
    expect(memoryDb.findTripChangeRequestById(request.id)).toMatchObject({
      status: "PENDING",
    });

    await expect(
      tripChangeRequestService.review(request.id, {
        decision: "REJECTED",
        adminNote: "Chuyến đi đã qua thời hạn hỗ trợ.",
      }),
    ).resolves.toMatchObject({
      request: {
        status: "REJECTED",
        refundAmount: null,
        adminNote: "Chuyến đi đã qua thời hạn hỗ trợ.",
      },
      trip: { status: "ONGOING", isUpcoming: true },
    });
  });

  it("lists the pending admin queue with its trip context", async () => {
    await tripChangeRequestService.create("user-1", "trip-1", {
      type: "REFUND",
      reason: "Tôi không thể tham gia chuyến đi này.",
    });

    await expect(
      tripChangeRequestService.listForAdmin("PENDING"),
    ).resolves.toMatchObject([
      {
        type: "REFUND",
        status: "PENDING",
        trip: { id: "trip-1", destination: "Đà Lạt", totalPrice: 1000000 },
      },
    ]);
  });

  it("maps a database pending-request uniqueness conflict to 409", async () => {
    mocks.shouldUseMemoryFallback.mockResolvedValue(false);
    mocks.transaction.mockImplementation((run) => run(persistentTransaction));
    mocks.findOwnedTrip.mockResolvedValue({
      id: "trip-1",
      userId: "user-1",
      status: "ONGOING",
      isUpcoming: true,
    });
    mocks.findPendingRequest.mockResolvedValue(null);
    mocks.createRequest.mockRejectedValue(
      new Prisma.PrismaClientKnownRequestError("duplicate pending request", {
        code: "P2002",
        clientVersion: "6.19.3",
      }),
    );

    await expect(
      tripChangeRequestService.create("user-1", "trip-1", {
        type: "REFUND",
        reason: "Tôi không thể tham gia chuyến đi này.",
      }),
    ).rejects.toMatchObject({ statusCode: 409 });
  });
});
