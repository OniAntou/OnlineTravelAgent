import { z } from "zod";
import { TripStatus } from "@prisma/client";

export const bookTripSchema = z.object({
  destinationId: z.string(),
  date: z.string().optional(),
  guests: z.string().optional(),
  totalPrice: z.number().min(0).optional(),
  requestId: z.string().optional(),
});

export const bookFlightSchema = z.object({
  flightId: z.string(),
  date: z.string().optional(),
  guests: z.string().optional(),
  requestId: z.string().optional(),
});

export const bookHotelSchema = z.object({
  roomId: z.string(),
  checkIn: z.string(),
  checkOut: z.string(),
  guests: z.string(),
  requestId: z.string().optional(),
});

export const bookTourSchema = z.object({
  tourId: z.string(),
  date: z.string().optional(),
  guests: z.string().optional(),
  totalPrice: z.number().min(0).optional(),
  requestId: z.string().optional(),
});

export const createCustomTourSchema = z.object({
  date: z.string().optional(),
  guests: z.string().optional(),
  location: z.string().optional(),
  imagePath: z.string().optional(),
  totalPrice: z.number().min(0).optional(),
  requestId: z.string().optional(),
});

export const createDocumentSchema = z.object({
  title: z.string(),
  description: z.string().optional(),
  icon: z.string().optional(),
  color: z.string().optional(),
});

export const createReviewSchema = z.object({
  targetType: z.enum(["destination", "hotel", "tour", "flight"]),
  targetId: z.string(),
  rating: z.number().min(1).max(5),
  comment: z.string().optional(),
});

export const updateTripSchema = z.object({
  status: z.nativeEnum(TripStatus).optional(),
  isUpcoming: z.boolean().optional(),
});
