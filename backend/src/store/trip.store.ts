import { Prisma } from "@prisma/client";
import prisma from "../config/prisma.js";
import { scheduleService } from "../services/schedule.service.js";
import { generateId, processTripStatus } from "./helpers.js";
import { TripStatus } from "@prisma/client";

export const tripStore = {
  async createTrip(
    userId: string | undefined,
    destinationId: string,
    date: string,
    guests: string,
    totalPrice?: number,
    requestId?: string,
  ) {
    if (requestId) {
      const existing = await prisma.trip.findUnique({ where: { requestId } });
      if (existing) return existing;
    }

    const destination = await prisma.destination.findUnique({
      where: { id: destinationId },
    });
    if (!destination) return null;

    const tripId = generateId("trip-dest");
    const trip = await prisma.trip.create({
      data: {
        id: tripId,
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

    try {
      await scheduleService.copyTemplateToTrip({
        tripId: trip.id,
        sourceType: "destination",
        sourceId: destination.id,
        tripDate: date,
      });
    } catch (e) {
      console.error("Failed to copy schedule template to trip", e);
    }

    return trip;
  },

  async bookFlightTrip(
    userId: string | undefined,
    flightId: string,
    date: string,
    guests: string,
    requestId?: string,
  ) {
    if (requestId) {
      const existing = await prisma.trip.findUnique({ where: { requestId } });
      if (existing) return existing;
    }

    const flight = await prisma.flight.findUnique({ where: { id: flightId } });
    if (!flight) {
      return null;
    }

    const tripId = generateId("trip-flight");
    return prisma.trip.create({
      data: {
        id: tripId,
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

  async createCustomTour(
    userId: string | undefined,
    data: {
      destinations: string[];
      date: string;
      guests: string;
      location: string;
      imagePath: string;
      totalPrice?: number;
      requestId?: string;
    },
  ) {
    if (data.requestId) {
      const existing = await prisma.trip.findUnique({
        where: { requestId: data.requestId },
      });
      if (existing) return existing;
    }

    const tripId = generateId("trip-custom");
    return prisma.trip.create({
      data: {
        id: tripId,
        userId,
        destination: "Tour thiết kế riêng",
        location: data.location,
        date: data.date,
        guests: data.guests,
        status: TripStatus.ONGOING,
        imagePath: data.imagePath,
        isUpcoming: true,
        totalPrice: data.totalPrice,
        isCustom: true,
        requestId: data.requestId,
      },
    });
  },

  async cancelTrip(userId: string | undefined, tripId: string) {
    const trip = await prisma.trip.findUnique({ where: { id: tripId } });
    if (!trip || (userId && trip.userId !== userId)) {
      return null;
    }

    return prisma.trip.update({
      where: { id: tripId },
      data: {
        status: TripStatus.CANCELLED,
        isUpcoming: false,
      },
    });
  },

  async getTrips(userId: string | undefined, type?: string) {
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
    const where: Prisma.FlightWhereInput = {};

    if (departure) {
      where.departure = { equals: departure, mode: "insensitive" };
    }
    if (arrival) {
      where.arrival = { equals: arrival, mode: "insensitive" };
    }

    return prisma.flight.findMany({ where });
  },
};
