import prisma from "../config/prisma.js";
import { scheduleService } from "../services/schedule.service.js";
import { attachRealReviews, generateId } from "./helpers.js";
import { TripStatus } from "@prisma/client";
import { mockTourPackages } from "../data/mock-data.js";

export const tourStore = {
  async getTours() {
    try {
      const tours = await prisma.tourPackage.findMany({ orderBy: { createdAt: "desc" } });
      return attachRealReviews(tours, "tour");
    } catch {
      return mockTourPackages;
    }
  },

  async getTourById(id: string) {
    try {
      const tour = await prisma.tourPackage.findUnique({ where: { id } });
      if (!tour) return null;
      const items = await attachRealReviews([tour], "tour");
      return items[0];
    } catch {
      return mockTourPackages.find((t) => t.id === id) || null;
    }
  },

  async getTourSchedule(tourId: string) {
    try {
      return await prisma.scheduleTemplate.findFirst({
        where: { tourPackageId: tourId },
        include: {
          days: {
            include: { items: { orderBy: { sortOrder: "asc" } } },
            orderBy: { dayNumber: "asc" },
          },
        },
      });
    } catch {
      return null;
    }
  },

  async bookTour(
    userId: string | undefined,
    tourId: string,
    date: string,
    guests: string,
    totalPrice?: number,
    requestId?: string,
  ) {
    if (requestId) {
      const existing = await prisma.trip.findFirst({ where: { userId, requestId } });
      if (existing) return existing;
    }

    const tour = await prisma.tourPackage.findUnique({ where: { id: tourId } });
    if (!tour) return null;

    const tripId = generateId("trip-tour");
    const trip = await prisma.trip.create({
      data: {
        id: tripId,
        userId,
        destination: tour.name,
        location: tour.departure,
        date,
        guests,
        status: TripStatus.ONGOING,
        imagePath: tour.imagePath,
        isUpcoming: true,
        tourPackageId: tour.id,
        totalPrice: totalPrice,
        requestId,
      },
    });

    try {
      await scheduleService.copyTemplateToTrip({
        tripId: trip.id,
        sourceType: "tour",
        sourceId: tour.id,
        tripDate: date,
      });
    } catch (e) {
      console.error("Failed to copy schedule template to trip", e);
    }

    return trip;
  },
};
