import { Prisma, TripStatus } from "@prisma/client";
import prisma from "../infrastructure/database/prisma.js";
import { generateId, processTripStatus } from "../core/data/store-helpers.js";
import { mockFlights, mockDestinations } from "../infrastructure/fallback/mock-data.js";
import { memoryDb } from "../infrastructure/fallback/memory-db.js";
import { assertMemoryFallbackEnabled } from "../core/config/data-availability.js";
import { scheduleService } from "../services/schedule.service.js";
import {
  findIdempotentTrip,
  recoverIdempotentTrip,
} from "./booking-idempotency.js";

async function dbAvailable(): Promise<boolean> {
  try {
    await prisma.$queryRaw`SELECT 1`;
    return true;
  } catch {
    return false;
  }
}

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
    totalPrice?: number,
    requestId?: string,
  ) {
    const useMem = !(await dbAvailable());

    if (useMem) {
      assertMemoryFallbackEnabled();
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
        status: "ONGOING",
        imagePath: destination.imagePath,
        isUpcoming: true,
        isCustom: false,
        totalPrice: totalPrice || null,
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
            status: TripStatus.ONGOING,
            imagePath: destination.imagePath,
            isUpcoming: true,
            destinationId: destination.id,
            totalPrice: totalPrice,
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
    const useMem = !(await dbAvailable());

    if (useMem) {
      assertMemoryFallbackEnabled();
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
        status: "ONGOING",
        imagePath: flight.airlineLogo,
        isUpcoming: true,
        isCustom: false,
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
          status: TripStatus.ONGOING,
          imagePath: flight.airlineLogo,
          isUpcoming: true,
          flightId: flight.id,
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

  async cancelTrip(userId: string | undefined, tripId: string) {
    const useMem = !(await dbAvailable());

    if (useMem) {
      assertMemoryFallbackEnabled();
      const trip = memoryDb.findTripById(tripId);
      if (!trip || (userId && trip.userId !== userId)) return null;
      return memoryDb.updateTrip(tripId, { status: "CANCELLED", isUpcoming: false });
    }

    const trip = await prisma.trip.findUnique({ where: { id: tripId } });
    if (!trip || (userId && trip.userId !== userId)) return null;

    return prisma.trip.update({
      where: { id: tripId },
      data: { status: TripStatus.CANCELLED, isUpcoming: false },
    });
  },

  async getTrips(userId: string | undefined, type?: string) {
    const useMem = !(await dbAvailable());

    if (useMem) {
      assertMemoryFallbackEnabled();
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
