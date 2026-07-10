import { z } from "zod";

export const adminDestinationSchema = z.object({
  id: z.string().optional(),
  name: z.string().min(1, "name is required"),
  location: z.string().min(1, "location is required"),
  category: z.string().optional(),
  rating: z.string().optional(),
  duration: z.string().optional(),
  imagePath: z.string().optional(),
  description: z.string().optional(),
  price: z.number().optional(),
  reviewsCount: z.string().optional(),
  isFavorite: z.boolean().optional(),
  isRecommended: z.boolean().optional(),
  latitude: z.number().nullable().optional(),
  longitude: z.number().nullable().optional(),
});

export const adminHotelSchema = z.object({
  id: z.string().optional(),
  name: z.string().min(1, "name is required"),
  location: z.string().min(1, "location is required"),
  address: z.string().optional(),
  rating: z.string().optional(),
  imagePath: z.string().optional(),
  description: z.string().optional(),
  priceFrom: z.number().optional(),
  amenities: z.array(z.string()).optional(),
  latitude: z.number().nullable().optional(),
  longitude: z.number().nullable().optional(),
});

export const adminFlightSchema = z.object({
  id: z.string().optional(),
  airline: z.string().min(1, "airline is required"),
  airlineLogo: z.string().optional(),
  departure: z.string().min(1, "departure is required"),
  arrival: z.string().min(1, "arrival is required"),
  departureTime: z.string().optional(),
  arrivalTime: z.string().optional(),
  price: z.number().optional(),
  duration: z.string().optional(),
});

export const adminTourSchema = z.object({
  id: z.string().optional(),
  name: z.string().min(1, "name is required"),
  description: z.string().optional(),
  imagePath: z.string().optional(),
  duration: z.string().optional(),
  price: z.number().optional(),
  originalPrice: z.number().nullable().optional(),
  destinations: z.array(z.string()).optional(),
  includes: z.array(z.string()).optional(),
  departure: z.string().optional(),
  departureDate: z.string().nullable().optional(),
  isPopular: z.boolean().optional(),
  includesGuide: z.boolean().optional(),
  guideFee: z.number().optional(),
});

export const adminTripSchema = z.object({
  status: z.string().optional(),
  isUpcoming: z.boolean().optional(),
});

export const adminCategorySchema = z.object({
  name: z.string().min(1, "name is required"),
});

export const adminRoomSchema = z.object({
  id: z.string().optional(),
  name: z.string().min(1, "name is required"),
  description: z.string().optional(),
  price: z.number().min(0, "price must be positive"),
  capacity: z.number().min(1, "capacity must be at least 1"),
  imagePath: z.string().optional(),
  amenities: z.array(z.string()).optional(),
});

export const adminUserSchema = z.object({
  name: z.string().min(1, "name is required"),
  email: z.string().email("invalid email"),
  password: z.string().min(6, "password must be at least 6 characters"),
});

export const adminDocumentSchema = z.object({
  id: z.string().optional(),
  title: z.string().min(1, "title is required"),
  description: z.string().optional(),
  icon: z.string().optional(),
  color: z.string().optional(),
});

const scheduleStatusSchema = z.enum([
  "completed",
  "ongoing",
  "upcoming",
  "cancelled",
  "delayed",
]);

const scheduleItemSchema = z.object({
  id: z.string().optional(),
  startTime: z
    .string()
    .regex(/^([01]\d|2[0-3]):[0-5]\d$/, "startTime must use HH:mm format"),
  endTime: z
    .string()
    .regex(/^([01]\d|2[0-3]):[0-5]\d$/, "endTime must use HH:mm format")
    .nullable()
    .optional(),
  title: z.string().trim().min(1, "title is required"),
  description: z.string().nullable().optional(),
  locationName: z.string().nullable().optional(),
  latitude: z.number().nullable().optional(),
  longitude: z.number().nullable().optional(),
  sortOrder: z.number().int().optional(),
  statusOverride: scheduleStatusSchema.nullable().optional(),
  note: z.string().nullable().optional(),
});

const scheduleDaySchema = z.object({
  id: z.string().optional(),
  dayNumber: z.number().int().min(1, "dayNumber must be positive"),
  date: z.string().nullable().optional(),
  title: z.string().nullable().optional(),
  items: z.array(scheduleItemSchema).optional(),
});

export const adminScheduleTemplateSchema = z.object({
  id: z.string().optional(),
  name: z.string().trim().min(1, "name is required"),
  sourceType: z.enum(["tour", "destination"]),
  tourPackageId: z.string().nullable().optional(),
  destinationId: z.string().nullable().optional(),
  days: z.array(scheduleDaySchema).optional(),
});
