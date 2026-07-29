import { Prisma, TripStatus } from "@prisma/client";
import prisma from "../../../infrastructure/database/prisma.js";
import { generateId, processTripStatus } from "../../../core/data/store-helpers.js";
import { mockFlights, mockDestinations } from "../../../infrastructure/fallback/mock-data.js";
import { memoryDb } from "../../../infrastructure/fallback/memory-db.js";
import {
  assertMemoryFallbackEnabled,
  shouldUseMemoryFallback,
} from "../../../core/config/data-availability.js";
import { scheduleService } from "../schedule.service.js";
import {
  findIdempotentTrip,
  recoverIdempotentTrip,
} from "../../booking/data/booking-idempotency.js";

function filterTripsByType<T extends { isUpcoming: boolean }>(
  trips: T[],
  type?: string,
) {
  if (type === "upcoming") return trips.filter((trip) => trip.isUpcoming);
  if (type === "past") return trips.filter((trip) => !trip.isUpcoming);
  return trips;
}

export const tripStore = {
  async createTrip(
    userId: string | undefined,
    destinationId: string,
    date: string,
    guests: string,
    _clientTotalPrice?: number,
    requestId?: string,
  ) {
    const useMem = await shouldUseMemoryFallback();

    if (useMem) {
      if (requestId) {
        const existing = memoryDb.findTripByRequestId(userId, requestId);
        if (existing) return existing;
      }
      const destination = mockDestinations.find((d) => d.id === destinationId);
      if (!destination) return null;
      return memoryDb.createTrip({
        id: generateId("trip-dest"),
        userId: userId || null,
        destination: destination.name,
        location: destination.location,
        date,
        guests,
        status: "PENDING",
        imagePath: destination.imagePath,
        isUpcoming: true,
        isCustom: false,
        totalPrice: Number(destination.price) || null,
        requestId: requestId || null,
      });
    }

    if (requestId) {
      const existing = await findIdempotentTrip(prisma, userId, requestId);
      if (existing) return existing;
    }

    try {
      return await prisma.$transaction(async (tx) => {
        const destination = await tx.destination.findUnique({
          where: { id: destinationId },
        });
        if (!destination) return null;

        const trip = await tx.trip.create({
          data: {
            id: generateId("trip-dest"),
            userId,
            destination: destination.name,
            location: destination.location,
            date,
            guests,
            status: TripStatus.PENDING,
            imagePath: destination.imagePath,
            isUpcoming: true,
            destinationId: destination.id,
            totalPrice: destination.price,
            requestId,
          },
        });
        await scheduleService.copyTemplateToTrip(
          {
            tripId: trip.id,
            sourceType: "destination",
            sourceId: destination.id,
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

  async bookFlightTrip(
    userId: string | undefined,
    flightId: string,
    date: string,
    guests: string,
    requestId?: string,
  ) {
    const useMem = await shouldUseMemoryFallback();

    if (useMem) {
      if (requestId) {
        const existing = memoryDb.findTripByRequestId(userId, requestId);
        if (existing) return existing;
      }
      const flight = mockFlights.find((f) => f.id === flightId);
      if (!flight) return null;
      return memoryDb.createTrip({
        id: generateId("trip-flight"),
        userId: userId || null,
        destination: `${flight.departure} ✈ ${flight.arrival}`,
        location: flight.airline,
        date,
        guests,
        status: "PENDING",
        imagePath: flight.airlineLogo,
        isUpcoming: true,
        isCustom: false,
        totalPrice: Number(flight.price) || null,
        requestId: requestId || null,
      });
    }

    if (requestId) {
      const existing = await findIdempotentTrip(prisma, userId, requestId);
      if (existing) return existing;
    }

    const flight = await prisma.flight.findUnique({ where: { id: flightId } });
    if (!flight) return null;

    try {
      return await prisma.trip.create({
        data: {
          id: generateId("trip-flight"),
          userId,
          destination: `${flight.departure} ✈ ${flight.arrival}`,
          location: flight.airline,
          date,
          guests,
          status: TripStatus.PENDING,
          imagePath: flight.airlineLogo,
          isUpcoming: true,
          flightId: flight.id,
          totalPrice: flight.price,
          requestId,
        },
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

  async getTrips(userId: string | undefined, type?: string) {
    const useMem = await shouldUseMemoryFallback();

    if (useMem) {
      if (!userId) return [];
      const trips = memoryDb
        .findTripsByUserId(userId)
        .map((trip) => processTripStatus(trip as any)) as Array<{
        isUpcoming: boolean;
      }>;
      return filterTripsByType(trips, type);
    }

    const where: Prisma.TripWhereInput = userId ? { userId } : {};
    const trips = await prisma.trip.findMany({
      where,
      orderBy: { createdAt: "desc" },
    });
    return filterTripsByType(trips.map(processTripStatus), type);
  },

  async searchFlights(departure?: string, arrival?: string) {
    try {
      const where: Prisma.FlightWhereInput = {};
      if (departure) where.departure = { equals: departure, mode: "insensitive" };
      if (arrival) where.arrival = { equals: arrival, mode: "insensitive" };
      return await prisma.flight.findMany({ where });
    } catch {
      assertMemoryFallbackEnabled();
      let results = mockFlights;
      if (departure) results = results.filter((f) => f.departure.toLowerCase() === departure.toLowerCase());
      if (arrival) results = results.filter((f) => f.arrival.toLowerCase() === arrival.toLowerCase());
      return results;
    }
  },
};
