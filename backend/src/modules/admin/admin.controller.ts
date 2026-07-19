import crypto from "crypto";
import { Prisma, ReviewTargetType, TripStatus } from "@prisma/client";
import { Request, Response } from "express";
import prisma from "../../infrastructure/database/prisma.js";
import { asyncHandler } from "../../core/utils/asyncHandler.js";
import { HttpError } from "../../core/utils/http-error.js";
import {
  scheduleService,
  ScheduleTemplateInput,
} from "../trips/schedule.service.js";
import { passwordService } from "../auth/password.service.js";
import { processTripStatus } from "../../core/data/store-helpers.js";
import { getTourScheduleRealtimeTarget } from "../trips/schedule-realtime.js";
import { deleteManagedPublicImages } from "../../core/storage/supabase-storage.js";
import { invalidateBootstrapUserCache } from "../../core/config/cache.js";
import { tripChangeRequestService } from "../trips/trip-change-request.service.js";
import { tripChangeRequestQuerySchema } from "../trips/trip-change-request.schema.js";
import {
  CreateDestinationBody,
  UpdateDestinationBody,
  CreateHotelBody,
  UpdateHotelBody,
  CreateFlightBody,
  UpdateFlightBody,
  CreateTourBody,
  UpdateTourBody,
  CreateRoomBody,
  UpdateRoomBody,
  CreateDocumentBody,
  UpdateDocumentBody,
  CreateCategoryBody,
  CreateUserBody,
  CreatePartnerBody,
  UpdatePartnerBody,
  UpdateTripBody,
  UpdateScheduleItemBody,
  CreateScheduleItemBody,
  CreateScheduleDayBody,
  UpdateScheduleDayBody,
  CreateScheduleUpdateBody,
} from "../../core/types/index.js";

function generateId(prefix: string = ""): string {
  return prefix ? `${prefix}-${crypto.randomUUID()}` : crypto.randomUUID();
}

async function deleteTargetReviews(
  tx: Prisma.TransactionClient,
  targetType: ReviewTargetType,
  targetId: string,
) {
  await tx.review.deleteMany({ where: { targetType, targetId } });
}

function replacedImagePath(previous: string, next: string | undefined): string[] {
  return next !== undefined && next !== previous ? [previous] : [];
}

async function requireDestinationCategory(category: string): Promise<string> {
  const existing = await prisma.category.findUnique({
    where: { name: category },
    select: { id: true },
  });
  if (!existing) throw new HttpError(400, "Category not found");
  return category;
}

async function removePartnerCatalog(partnerId: string): Promise<void> {
  const partner = await prisma.user.findFirst({
    where: { id: partnerId, role: "PARTNER" },
    select: {
      hotels: { select: { id: true, imagePath: true, rooms: { select: { imagePath: true } } } },
      tours: { select: { id: true, imagePath: true } },
    },
  });
  if (!partner) throw new HttpError(404, "Partner not found");
  const hotelIds = partner.hotels.map((hotel) => hotel.id);
  const tourIds = partner.tours.map((tour) => tour.id);
  const imagePaths = [
    ...partner.hotels.flatMap((hotel) => [hotel.imagePath, ...hotel.rooms.map((room) => room.imagePath)]),
    ...partner.tours.map((tour) => tour.imagePath),
  ];
  await prisma.$transaction(async (tx) => {
    await tx.scheduleTemplate.deleteMany({ where: { tourPackageId: { in: tourIds } } });
    await tx.review.deleteMany({ where: { OR: [
      { targetType: ReviewTargetType.hotel, targetId: { in: hotelIds } },
      { targetType: ReviewTargetType.tour, targetId: { in: tourIds } },
    ] } });
    await tx.room.deleteMany({ where: { hotelId: { in: hotelIds } } });
    await tx.hotel.deleteMany({ where: { id: { in: hotelIds } } });
    await tx.tourPackage.deleteMany({ where: { id: { in: tourIds } } });
  });
  await deleteManagedPublicImages(imagePaths);
}

const allowedScheduleStatuses = new Set([
  "completed",
  "ongoing",
  "upcoming",
  "cancelled",
  "delayed",
]);

function isClockTime(value: string): boolean {
  return /^([01]\d|2[0-3]):[0-5]\d$/.test(value);
}

function emitScheduleUpdated(req: Request, tripId: string) {
  const io = req.app.get("io");
  if (io) {
    io.to(`trip_${tripId}`).emit("schedule_updated", { tripId });
  }
}

function emitTourTemplateUpdated(
  req: Request,
  ...templates: Array<{
    sourceType?: string | null;
    tourPackageId?: string | null;
  } | null>
) {
  const io = req.app.get("io");
  if (!io) return;

  const emittedRooms = new Set<string>();
  for (const template of templates) {
    const target = getTourScheduleRealtimeTarget(template);
    if (!target || emittedRooms.has(target.room)) continue;
    emittedRooms.add(target.room);
    io.to(target.room).emit("schedule_updated", target.payload);
  }
}

function validateScheduleItemUpdate(
  body: UpdateScheduleItemBody,
): string | null {
  if (body.startTime !== undefined && !isClockTime(body.startTime)) {
    return "startTime must use HH:mm format";
  }
  if (
    body.endTime !== undefined &&
    body.endTime !== null &&
    body.endTime !== "" &&
    !isClockTime(body.endTime)
  ) {
    return "endTime must use HH:mm format";
  }
  if (body.title !== undefined && !body.title.trim()) {
    return "title is required";
  }
  if (
    body.statusOverride !== undefined &&
    body.statusOverride !== null &&
    body.statusOverride !== "" &&
    !allowedScheduleStatuses.has(body.statusOverride)
  ) {
    return "invalid schedule item statusOverride";
  }
  return null;
}

export const adminController = {
  getStats: asyncHandler(async (_: Request, res: Response) => {
    const [destinations, hotels, flights, tours, trips] =
      await Promise.all([
        prisma.destination.count(),
        prisma.hotel.count(),
        prisma.flight.count(),
        prisma.tourPackage.count(),
        prisma.trip.findMany({
          select: { date: true, status: true, isUpcoming: true },
        }),
      ]);
    const normalizedTrips = trips.map(processTripStatus);
    const tripsUpcoming = normalizedTrips.filter((trip) => trip.isUpcoming).length;
    const tripsHistory = normalizedTrips.length - tripsUpcoming;
    const tripsPending = normalizedTrips.filter(
      (trip) => trip.status === TripStatus.PENDING,
    ).length;
    res.json({
      destinations,
      hotels,
      flights,
      tours,
      tripsPending,
      tripsUpcoming,
      tripsHistory,
    });
  }),

  // --- Destinations ---
  getDestinations: asyncHandler(async (_: Request, res: Response) => {
    const data = await prisma.destination.findMany({
      orderBy: { name: "asc" },
    });
    res.json(data);
  }),

  createDestination: asyncHandler(async (req: Request, res: Response) => {
    const body = req.body as CreateDestinationBody;
    const category = await requireDestinationCategory(
      body.category?.trim() || "Địa điểm",
    );
    const dest = await prisma.destination.create({
      data: {
        id: body.id || generateId("dest"),
        name: body.name,
        location: body.location,
        category,
        rating: body.rating || "4.0",
        duration: body.duration || "2N/1Đ",
        imagePath: body.imagePath || "",
        description: body.description || "",
        price: body.price ?? 0,
        reviewsCount: body.reviewsCount || "0",
        isFavorite: body.isFavorite ?? false,
        isRecommended: body.isRecommended ?? false,
        latitude: body.latitude ?? null,
        longitude: body.longitude ?? null,
      },
    });
    res.status(201).json(dest);
  }),

  updateDestination: asyncHandler(async (req: Request, res: Response) => {
    const body = req.body as UpdateDestinationBody;
    const category = body.category === undefined
      ? undefined
      : await requireDestinationCategory(body.category.trim());
    const previous = await prisma.destination.findUnique({
      where: { id: req.params.id as string },
      select: { imagePath: true },
    });
    const dest = await prisma.destination.update({
      where: { id: req.params.id as string },
      data: {
        name: body.name,
        location: body.location,
        category,
        rating: body.rating,
        duration: body.duration,
        imagePath: body.imagePath,
        description: body.description,
        price: body.price,
        reviewsCount: body.reviewsCount,
        isFavorite: body.isFavorite,
        isRecommended: body.isRecommended,
        latitude: body.latitude,
        longitude: body.longitude,
      },
    });
    await deleteManagedPublicImages(replacedImagePath(previous?.imagePath ?? "", body.imagePath));
    res.json(dest);
  }),

  deleteDestination: asyncHandler(async (req: Request, res: Response) => {
    const id = req.params.id as string;
    const previous = await prisma.destination.findUnique({
      where: { id },
      select: { imagePath: true },
    });
    await prisma.$transaction(async (tx) => {
      await deleteTargetReviews(tx, ReviewTargetType.destination, id);
      await tx.destination.delete({ where: { id } });
    });
    await deleteManagedPublicImages([previous?.imagePath ?? ""]);
    res.json({ ok: true });
  }),

  // --- Hotels ---
  getHotels: asyncHandler(async (_: Request, res: Response) => {
    const data = await prisma.hotel.findMany({
      include: { rooms: true },
      orderBy: { name: "asc" },
    });
    res.json(data);
  }),

  createHotel: asyncHandler(async (req: Request, res: Response) => {
    const body = req.body as CreateHotelBody;
    const hotel = await prisma.hotel.create({
      data: {
        id: body.id || generateId("hotel"),
        name: body.name,
        location: body.location,
        address: body.address || "",
        rating: body.rating || "4.0",
        imagePath: body.imagePath || "",
        description: body.description || "",
        priceFrom: body.priceFrom || 0,
        amenities: body.amenities || [],
        latitude: body.latitude ?? null,
        longitude: body.longitude ?? null,
      },
    });
    res.status(201).json(hotel);
  }),

  updateHotel: asyncHandler(async (req: Request, res: Response) => {
    const body = req.body as UpdateHotelBody;
    const previous = await prisma.hotel.findUnique({
      where: { id: req.params.id as string },
      select: { imagePath: true },
    });
    const hotel = await prisma.hotel.update({
      where: { id: req.params.id as string },
      data: {
        name: body.name,
        location: body.location,
        address: body.address,
        rating: body.rating,
        imagePath: body.imagePath,
        description: body.description,
        priceFrom: body.priceFrom,
        amenities: body.amenities,
        latitude: body.latitude,
        longitude: body.longitude,
      },
    });
    await deleteManagedPublicImages(replacedImagePath(previous?.imagePath ?? "", body.imagePath));
    res.json(hotel);
  }),

  deleteHotel: asyncHandler(async (req: Request, res: Response) => {
    const id = req.params.id as string;
    const previous = await prisma.hotel.findUnique({
      where: { id },
      select: { imagePath: true, rooms: { select: { imagePath: true } } },
    });
    await prisma.$transaction(async (tx) => {
      await deleteTargetReviews(tx, ReviewTargetType.hotel, id);
      await tx.room.deleteMany({ where: { hotelId: id } });
      await tx.hotel.delete({ where: { id } });
    });
    await deleteManagedPublicImages([
      previous?.imagePath ?? "",
      ...(previous?.rooms.map((room) => room.imagePath) ?? []),
    ]);
    res.json({ ok: true });
  }),

  // --- Flights ---
  getFlights: asyncHandler(async (_: Request, res: Response) => {
    const data = await prisma.flight.findMany({ orderBy: { airline: "asc" } });
    res.json(data);
  }),

  createFlight: asyncHandler(async (req: Request, res: Response) => {
    const body = req.body as CreateFlightBody;
    const flight = await prisma.flight.create({
      data: {
        id: body.id || generateId("fl"),
        airline: body.airline,
        airlineLogo: body.airlineLogo || "",
        departure: body.departure,
        arrival: body.arrival,
        departureTime: body.departureTime || "",
        arrivalTime: body.arrivalTime || "",
        price: body.price || 0,
        duration: body.duration || "",
      },
    });
    res.status(201).json(flight);
  }),

  updateFlight: asyncHandler(async (req: Request, res: Response) => {
    const body = req.body as UpdateFlightBody;
    const previous = await prisma.flight.findUnique({
      where: { id: req.params.id as string },
      select: { airlineLogo: true },
    });
    const flight = await prisma.flight.update({
      where: { id: req.params.id as string },
      data: {
        airline: body.airline,
        airlineLogo: body.airlineLogo,
        departure: body.departure,
        arrival: body.arrival,
        departureTime: body.departureTime,
        arrivalTime: body.arrivalTime,
        price: body.price,
        duration: body.duration,
      },
    });
    await deleteManagedPublicImages(replacedImagePath(previous?.airlineLogo ?? "", body.airlineLogo));
    res.json(flight);
  }),

  deleteFlight: asyncHandler(async (req: Request, res: Response) => {
    const id = req.params.id as string;
    const previous = await prisma.flight.findUnique({
      where: { id },
      select: { airlineLogo: true },
    });
    await prisma.$transaction(async (tx) => {
      await deleteTargetReviews(tx, ReviewTargetType.flight, id);
      await tx.flight.delete({ where: { id } });
    });
    await deleteManagedPublicImages([previous?.airlineLogo ?? ""]);
    res.json({ ok: true });
  }),

  // --- Tours ---
  getTours: asyncHandler(async (_: Request, res: Response) => {
    const data = await prisma.tourPackage.findMany({
      orderBy: { createdAt: "desc" },
    });
    res.json(data);
  }),

  createTour: asyncHandler(async (req: Request, res: Response) => {
    const body = req.body as CreateTourBody;
    const tour = await prisma.tourPackage.create({
      data: {
        id: body.id || generateId("tour"),
        name: body.name,
        description: body.description || "",
        imagePath: body.imagePath || "",
        duration: body.duration || "",
        price: body.price || 0,
        originalPrice: body.originalPrice ?? null,
        destinations: body.destinations || [],
        includes: body.includes || [],
        departure: body.departure || "",
        departureDate: body.departureDate || null,
        isPopular: body.isPopular ?? false,
        includesGuide: body.includesGuide ?? true,
        guideFee: body.guideFee ?? 50,
      },
    });
    res.status(201).json(tour);
  }),

  updateTour: asyncHandler(async (req: Request, res: Response) => {
    const body = req.body as UpdateTourBody;
    const previous = await prisma.tourPackage.findUnique({
      where: { id: req.params.id as string },
      select: { imagePath: true },
    });
    const tour = await prisma.tourPackage.update({
      where: { id: req.params.id as string },
      data: {
        name: body.name,
        description: body.description,
        imagePath: body.imagePath,
        duration: body.duration,
        price: body.price,
        originalPrice: body.originalPrice,
        destinations: body.destinations,
        includes: body.includes,
        departure: body.departure,
        departureDate: body.departureDate ?? undefined,
        isPopular: body.isPopular,
        includesGuide: body.includesGuide,
        guideFee: body.guideFee,
      },
    });
    await deleteManagedPublicImages(replacedImagePath(previous?.imagePath ?? "", body.imagePath));
    res.json(tour);
  }),

  deleteTour: asyncHandler(async (req: Request, res: Response) => {
    const id = req.params.id as string;
    const previous = await prisma.tourPackage.findUnique({
      where: { id },
      select: { imagePath: true },
    });
    await prisma.$transaction(async (tx) => {
      await deleteTargetReviews(tx, ReviewTargetType.tour, id);
      await tx.tourPackage.delete({ where: { id } });
    });
    await deleteManagedPublicImages([previous?.imagePath ?? ""]);
    res.json({ ok: true });
  }),

  // --- Trips ---
  getTripChangeRequests: asyncHandler(async (req: Request, res: Response) => {
    const { status } = tripChangeRequestQuerySchema.parse(req.query);
    const requests = await tripChangeRequestService.listForAdmin(status);
    res.json(requests);
  }),

  reviewTripChangeRequest: asyncHandler(async (req: Request, res: Response) => {
    const result = await tripChangeRequestService.review(
      req.params.id as string,
      req.body,
    );
    if (result.trip.userId) {
      invalidateBootstrapUserCache(result.trip.userId);
    }
    res.json(result.request);
  }),

  getTrips: asyncHandler(async (_: Request, res: Response) => {
    const data = await prisma.trip.findMany({ orderBy: { createdAt: "desc" } });
    res.json(data);
  }),

  updateTrip: asyncHandler(async (req: Request, res: Response) => {
    const body = req.body as UpdateTripBody;
    const isUpcoming =
      body.status === TripStatus.PENDING
        ? true
        : body.status === TripStatus.COMPLETED || body.status === TripStatus.CANCELLED
          ? false
          : body.isUpcoming;
    const trip = await prisma.trip.update({
      where: { id: req.params.id as string },
      data: { status: body.status, isUpcoming },
    });
    res.json(trip);
  }),

  deleteTrip: asyncHandler(async (req: Request, res: Response) => {
    await prisma.trip.delete({ where: { id: req.params.id as string } });
    res.json({ ok: true });
  }),

  getScheduleTemplates: asyncHandler(async (_: Request, res: Response) => {
    const templates = await scheduleService.getScheduleTemplates();
    res.json(templates);
  }),

  createScheduleTemplate: asyncHandler(async (req: Request, res: Response) => {
    try {
      const template = await scheduleService.createScheduleTemplate(
        req.body as ScheduleTemplateInput,
      );
      emitTourTemplateUpdated(req, template);
      res.status(201).json(template);
    } catch (error) {
      res.status(400).json({
        message:
          error instanceof Error ? error.message : "Invalid schedule template",
      });
    }
  }),

  updateScheduleTemplate: asyncHandler(async (req: Request, res: Response) => {
    const id = req.params.id as string;
    const existing = await prisma.scheduleTemplate.findUnique({
      where: { id },
      select: { id: true, sourceType: true, tourPackageId: true },
    });
    if (!existing) {
      res.status(404).json({ message: "Schedule template not found" });
      return;
    }

    try {
      const template = await scheduleService.updateScheduleTemplate(
        id,
        req.body as ScheduleTemplateInput,
      );
      emitTourTemplateUpdated(req, existing, template);
      res.json(template);
    } catch (error) {
      res.status(400).json({
        message:
          error instanceof Error ? error.message : "Invalid schedule template",
      });
    }
  }),

  deleteScheduleTemplate: asyncHandler(async (req: Request, res: Response) => {
    const id = req.params.id as string;
    const existing = await prisma.scheduleTemplate.findUnique({
      where: { id },
      select: { id: true, sourceType: true, tourPackageId: true },
    });
    if (!existing) {
      res.status(404).json({ message: "Schedule template not found" });
      return;
    }

    await scheduleService.deleteScheduleTemplate(id);
    emitTourTemplateUpdated(req, existing);
    res.json({ ok: true });
  }),

  getTripSchedule: asyncHandler(async (req: Request, res: Response) => {
    const tripId = req.params.id as string;
    const days = await prisma.tripScheduleDay.findMany({
      where: { tripId },
      include: {
        items: {
          orderBy: { sortOrder: "asc" },
        },
      },
      orderBy: { dayNumber: "asc" },
    });
    const updates = await prisma.tripScheduleUpdate.findMany({
      where: { tripId },
      orderBy: { createdAt: "desc" },
    });
    res.json({ days, updates });
  }),

  updateTripScheduleItem: asyncHandler(async (req: Request, res: Response) => {
    const tripId = req.params.id as string;
    const itemId = req.params.itemId as string;
    const body = req.body as UpdateScheduleItemBody;
    const validationError = validateScheduleItemUpdate(body);
    if (validationError) {
      res.status(400).json({ message: validationError });
      return;
    }

    const existing = await prisma.tripScheduleItem.findFirst({
      where: { id: itemId, day: { tripId } },
      select: { id: true },
    });
    if (!existing) {
      res.status(404).json({ message: "Item not found" });
      return;
    }

    const data: Record<string, any> = {};
    if (body.startTime !== undefined) data.startTime = body.startTime;
    if (body.endTime !== undefined) data.endTime = body.endTime || null;
    if (body.title !== undefined) data.title = body.title;
    if (body.description !== undefined)
      data.description = body.description || null;
    if (body.locationName !== undefined)
      data.locationName = body.locationName || null;
    if (body.latitude !== undefined) data.latitude = body.latitude;
    if (body.longitude !== undefined) data.longitude = body.longitude;
    if (body.sortOrder !== undefined) data.sortOrder = body.sortOrder;
    if (body.statusOverride !== undefined)
      data.statusOverride = body.statusOverride || null;
    if (body.note !== undefined) data.note = body.note || null;
    const item = await prisma.tripScheduleItem.update({
      where: { id: itemId },
      data,
    });
    emitScheduleUpdated(req, tripId);
    res.json(item);
  }),

  createTripScheduleUpdate: asyncHandler(
    async (req: Request, res: Response) => {
      const tripId = req.params.id as string;
      const body = req.body as CreateScheduleUpdateBody;
      const message =
        typeof body.message === "string" ? body.message.trim() : "";
      if (!message) {
        res.status(400).json({ message: "message is required" });
        return;
      }

      const update = await scheduleService.createTripScheduleUpdate(
        tripId,
        message,
      );
      if (!update) {
        res.status(404).json({ message: "Trip not found" });
        return;
      }

      emitScheduleUpdated(req, tripId);

      res.status(201).json(update);
    },
  ),

  deleteTripScheduleUpdate: asyncHandler(
    async (req: Request, res: Response) => {
      const tripId = req.params.id as string;
      const updateId = req.params.updateId as string;
      try {
        await scheduleService.deleteTripScheduleUpdate(tripId, updateId);
        emitScheduleUpdated(req, tripId);
        res.json({ ok: true });
      } catch {
        res.status(404).json({ message: "Schedule update not found" });
      }
    },
  ),

  createTripScheduleItem: asyncHandler(async (req: Request, res: Response) => {
    const tripId = req.params.id as string;
    const body = req.body as CreateScheduleItemBody;
    const result = await scheduleService.addTripScheduleItem(tripId, {
      dayId: body.dayId,
      startTime: body.startTime,
      endTime: body.endTime,
      title: body.title,
      description: body.description,
      locationName: body.locationName,
      latitude: body.latitude,
      longitude: body.longitude,
      sortOrder: body.sortOrder,
      statusOverride: body.statusOverride,
      note: body.note,
    });
    if (!result) {
      res.status(404).json({ message: "Day not found" });
      return;
    }
    emitScheduleUpdated(req, tripId);
    res.status(201).json(result);
  }),

  deleteTripScheduleItem: asyncHandler(async (req: Request, res: Response) => {
    const tripId = req.params.id as string;
    const itemId = req.params.itemId as string;
    const result = await scheduleService.deleteTripScheduleItem(tripId, itemId);
    if (!result) {
      res.status(404).json({ message: "Item not found" });
      return;
    }
    emitScheduleUpdated(req, tripId);
    res.json({ ok: true });
  }),

  createTripScheduleDay: asyncHandler(async (req: Request, res: Response) => {
    const tripId = req.params.id as string;
    const body = req.body as CreateScheduleDayBody;
    const result = await scheduleService.addTripScheduleDay(tripId, {
      dayNumber: body.dayNumber,
      title: body.title,
    });
    if (!result) {
      res.status(404).json({ message: "Trip not found" });
      return;
    }
    emitScheduleUpdated(req, tripId);
    res.status(201).json(result);
  }),

  deleteTripScheduleDay: asyncHandler(async (req: Request, res: Response) => {
    const tripId = req.params.id as string;
    const dayId = req.params.dayId as string;
    const result = await scheduleService.deleteTripScheduleDay(tripId, dayId);
    if (!result) {
      res.status(404).json({ message: "Day not found" });
      return;
    }
    emitScheduleUpdated(req, tripId);
    res.json({ ok: true });
  }),

  updateTripScheduleDay: asyncHandler(async (req: Request, res: Response) => {
    const tripId = req.params.id as string;
    const dayId = req.params.dayId as string;
    const body = req.body as UpdateScheduleDayBody;
    const day = await prisma.tripScheduleDay.findFirst({
      where: { id: dayId, tripId },
    });
    if (!day) {
      res.status(404).json({ message: "Day not found" });
      return;
    }
    const updated = await prisma.tripScheduleDay.update({
      where: { id: dayId },
      data: { title: body.title ?? null },
    });
    emitScheduleUpdated(req, tripId);
    res.json(updated);
  }),

  // --- Categories ---
  getCategories: asyncHandler(async (_: Request, res: Response) => {
    const data = await prisma.category.findMany({ orderBy: { name: "asc" } });
    res.json(data);
  }),

  createCategory: asyncHandler(async (req: Request, res: Response) => {
    const body = req.body as CreateCategoryBody;
    const cat = await prisma.category.create({ data: { name: body.name } });
    res.status(201).json(cat);
  }),

  deleteCategory: asyncHandler(async (req: Request, res: Response) => {
    const id = req.params.id as string;
    const category = await prisma.category.findUnique({
      where: { id },
      select: {
        id: true,
        _count: { select: { destinations: true } },
      },
    });
    if (!category) {
      throw new HttpError(404, "Category not found");
    }
    if (category._count.destinations > 0) {
      throw new HttpError(409, "Category is still assigned to destinations");
    }
    await prisma.category.delete({ where: { id } });
    res.json({ ok: true });
  }),

  // --- Users ---
  getUsers: asyncHandler(async (_: Request, res: Response) => {
    const data = await prisma.user.findMany({
      where: { role: "USER" },
      orderBy: { createdAt: "desc" },
      select: { id: true, name: true, email: true, createdAt: true },
    });
    res.json(data);
  }),

  createUser: asyncHandler(async (req: Request, res: Response) => {
    const body = req.body as CreateUserBody;
    const password = await passwordService.hash(body.password);
    const user = await prisma.user.create({
      data: { name: body.name, email: body.email, password },
    });
    res.status(201).json({ id: user.id, name: user.name, email: user.email });
  }),

  deleteUser: asyncHandler(async (req: Request, res: Response) => {
    const id = req.params.id as string;
    await prisma.$transaction(async (tx) => {
      await tx.review.deleteMany({ where: { userId: id } });
      await tx.user.delete({ where: { id } });
    });
    res.json({ ok: true });
  }),

  // --- Partners ---
  getPartners: asyncHandler(async (_: Request, res: Response) => {
    const data = await prisma.user.findMany({
      where: { role: "PARTNER" },
      orderBy: { createdAt: "desc" },
      select: {
        id: true,
        name: true,
        email: true,
        createdAt: true,
        _count: { select: { hotels: true, tours: true } },
      },
    });
    res.json(data);
  }),

  createPartner: asyncHandler(async (req: Request, res: Response) => {
    const body = req.body as CreatePartnerBody;
    const password = await passwordService.hash(body.password);
    const partner = await prisma.user.create({
      data: {
        name: body.name,
        email: body.email,
        password,
        role: "PARTNER",
      },
    });
    res.status(201).json({
      id: partner.id,
      name: partner.name,
      email: partner.email,
      role: partner.role,
    });
  }),

  updatePartner: asyncHandler(async (req: Request, res: Response) => {
    const body = req.body as UpdatePartnerBody;
    const id = req.params.id as string;
    const existing = await prisma.user.findFirst({ where: { id, role: "PARTNER" }, select: { id: true } });
    if (!existing) throw new HttpError(404, "Partner not found");
    const password = body.password ? await passwordService.hash(body.password) : undefined;
    const partner = await prisma.user.update({
      where: { id }, data: { name: body.name, email: body.email, ...(password ? { password } : {}) },
    });
    res.json({ id: partner.id, name: partner.name, email: partner.email, role: partner.role });
  }),

  promoteUserToPartner: asyncHandler(async (req: Request, res: Response) => {
    const id = req.params.id as string;
    const existing = await prisma.user.findUnique({ where: { id }, select: { role: true } });
    if (!existing) throw new HttpError(404, "User not found");
    if (existing.role === "PARTNER") throw new HttpError(409, "User is already a partner");
    const partner = await prisma.user.update({ where: { id }, data: { role: "PARTNER" } });
    res.json({ id: partner.id, name: partner.name, email: partner.email, role: partner.role });
  }),

  demotePartner: asyncHandler(async (req: Request, res: Response) => {
    const id = req.params.id as string;
    await removePartnerCatalog(id);
    const user = await prisma.user.update({ where: { id }, data: { role: "USER" } });
    res.json({ id: user.id, name: user.name, email: user.email, role: user.role });
  }),

  deletePartner: asyncHandler(async (req: Request, res: Response) => {
    const id = req.params.id as string;
    await removePartnerCatalog(id);
    await prisma.$transaction(async (tx) => {
      await tx.review.deleteMany({ where: { userId: id } });
      await tx.user.delete({ where: { id } });
    });
    res.json({ ok: true });
  }),

  // --- Rooms ---
  getRooms: asyncHandler(async (req: Request, res: Response) => {
    const data = await prisma.room.findMany({
      where: { hotelId: req.params.hotelId as string },
      orderBy: { name: "asc" },
    });
    res.json(data);
  }),

  createRoom: asyncHandler(async (req: Request, res: Response) => {
    const body = req.body as CreateRoomBody;
    const room = await prisma.room.create({
      data: {
        id: body.id || generateId("room"),
        hotelId: req.params.hotelId as string,
        name: body.name,
        description: body.description || "",
        price: body.price,
        capacity: body.capacity,
        imagePath: body.imagePath || "",
        amenities: body.amenities || [],
      },
    });
    res.status(201).json(room);
  }),

  updateRoom: asyncHandler(async (req: Request, res: Response) => {
    const body = req.body as UpdateRoomBody;
    const previous = await prisma.room.findUnique({
      where: { id: req.params.roomId as string },
      select: { imagePath: true },
    });
    const room = await prisma.room.update({
      where: { id: req.params.roomId as string },
      data: {
        name: body.name,
        description: body.description,
        price: body.price,
        capacity: body.capacity,
        imagePath: body.imagePath,
        amenities: body.amenities,
      },
    });
    await deleteManagedPublicImages(replacedImagePath(previous?.imagePath ?? "", body.imagePath));
    res.json(room);
  }),

  deleteRoom: asyncHandler(async (req: Request, res: Response) => {
    const id = req.params.roomId as string;
    const previous = await prisma.room.findUnique({
      where: { id },
      select: { imagePath: true },
    });
    await prisma.room.delete({ where: { id } });
    await deleteManagedPublicImages([previous?.imagePath ?? ""]);
    res.json({ ok: true });
  }),

  // --- Documents ---
  getDocuments: asyncHandler(async (_: Request, res: Response) => {
    const data = await prisma.documentItem.findMany({
      orderBy: { createdAt: "desc" },
    });
    res.json(data);
  }),

  createDocument: asyncHandler(async (req: Request, res: Response) => {
    const body = req.body as CreateDocumentBody;
    const doc = await prisma.documentItem.create({
      data: {
        id: body.id || generateId("doc"),
        title: body.title,
        description: body.description || "",
        icon: body.icon || "fa-file",
        color: body.color || "text-gray-500",
      },
    });
    res.status(201).json(doc);
  }),

  updateDocument: asyncHandler(async (req: Request, res: Response) => {
    const body = req.body as UpdateDocumentBody;
    const doc = await prisma.documentItem.update({
      where: { id: req.params.id as string },
      data: {
        title: body.title,
        description: body.description,
        icon: body.icon,
        color: body.color,
      },
    });
    res.json(doc);
  }),

  deleteDocument: asyncHandler(async (req: Request, res: Response) => {
    await prisma.documentItem.delete({
      where: { id: req.params.id as string },
    });
    res.json({ ok: true });
  }),
};
