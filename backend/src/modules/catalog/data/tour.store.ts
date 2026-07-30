import prisma from "../../../infrastructure/database/prisma.js";
import { scheduleService } from "../../trips/schedule.service.js";
import { attachRealReviews, generateId } from "../../../core/data/store-helpers.js";
import { TripStatus } from "@prisma/client";
import { mockTourPackages } from "../../../infrastructure/fallback/mock-data.js";
import { assertMemoryFallbackEnabled } from "../../../core/config/data-availability.js";
import {
  findIdempotentTrip,
  recoverIdempotentTrip,
} from "../../booking/data/booking-idempotency.js";


export const tourStore = {
  async getTours() {
    try {
      const tours = await prisma.tourPackage.findMany({ orderBy: { createdAt: "desc" } });
      return attachRealReviews(tours, "tour");
    } catch (error) {
      console.error("[tour.store] Error fetching tours:", error);
      try {
        assertMemoryFallbackEnabled();
        return mockTourPackages;
      } catch {
        throw error;
      }
    }
  },

  async getTourById(id: string) {
    try {
      const tour = await prisma.tourPackage.findUnique({ where: { id } });
      if (!tour) return null;
      const items = await attachRealReviews([tour], "tour");
      return items[0];
    } catch (error) {
      console.error(`[tour.store] Error fetching tour by ID ${id}:`, error);
      try {
        assertMemoryFallbackEnabled();
        return mockTourPackages.find((t) => t.id === id) || null;
      } catch {
        throw error;
      }
    }
  },

  async getTourSchedule(tourId: string) {
    try {
      return await prisma.scheduleTemplate.findUnique({
        where: {
          sourceType_tourPackageId: {
            sourceType: "tour",
            tourPackageId: tourId,
          },
        },
        include: {
          days: {
            include: { items: { orderBy: { sortOrder: "asc" } } },
            orderBy: { dayNumber: "asc" },
          },
        },
      });
    } catch (error) {
      console.error(`[tour.store] Error fetching tour schedule for ${tourId}:`, error);
      throw error;
    }
  },

  async bookTour(
    userId: string | undefined,
    tourId: string,
    date: string,
    guests: string,
    _clientTotalPrice?: number,
    requestId?: string,
  ) {
    if (requestId) {
      const existing = await findIdempotentTrip(prisma, userId, requestId);
      if (existing) return existing;
    }

    try {
      return await prisma.$transaction(async (tx) => {
        const tour = await tx.tourPackage.findUnique({ where: { id: tourId } });
        if (!tour) return null;

        const trip = await tx.trip.create({
          data: {
            id: generateId("trip-tour"),
            userId,
            destination: tour.name,
            location: tour.departure,
            date,
            guests,
            status: TripStatus.PENDING,
            imagePath: tour.imagePath,
            isUpcoming: true,
            tourPackageId: tour.id,
            totalPrice: tour.price,
            requestId,
          },
        });

        await scheduleService.copyTemplateToTrip(
          {
            tripId: trip.id,
            sourceType: "tour",
            sourceId: tour.id,
            tripDate: date,
          },
          tx,
        );
        return trip;
      });
    } catch (error) {
      const existing = await recoverIdempotentTrip(
        error,
        prisma,
        userId,
        requestId,
      );
      if (existing) return existing;
      throw error;
    }
  },
};
