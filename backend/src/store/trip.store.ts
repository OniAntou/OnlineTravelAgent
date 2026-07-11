import { Prisma, TripStatus } from "@prisma/client";
import prisma from "../config/prisma.js";
import { generateId, processTripStatus } from "./helpers.js";
import { mockFlights, mockDestinations } from "../data/mock-data.js";
import { memoryDb } from "./memory-db.js";
import { assertMemoryFallbackEnabled } from "../config/data-availability.js";

async function dbAvailable(): Promise<boolean> {
  try {
    await prisma.$queryRaw`SELECT 1`;
    return true;
  } catch {
    return false;
  }
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
      const existing = await prisma.trip.findFirst({ where: { userId, requestId } });
      if (existing) return existing;
    }

    const destination = await prisma.destination.findUnique({
      where: { id: destinationId },
    });
    if (!destination) return null;

    return prisma.trip.create({
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
      const existing = await prisma.trip.findFirst({ where: { userId, requestId } });
      if (existing) return existing;
    }

    const flight = await prisma.flight.findUnique({ where: { id: flightId } });
    if (!flight) return null;

    return prisma.trip.create({
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
      return memoryDb.findTripsByUserId(userId, type).map(processTripStatus as any);
    }

    const where: Prisma.TripWhereInput = userId ? { userId } : {};
    if (type === "upcoming") where.isUpcoming = true;
    if (type === "past") where.isUpcoming = false;
    const trips = await prisma.trip.findMany({
      where,
      orderBy: { createdAt: "desc" },
    });
    return trips.map(processTripStatus);
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
