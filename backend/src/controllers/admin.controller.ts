import crypto from "crypto";
import { Request, Response } from "express";
import prisma from "../config/prisma.js";
import { asyncHandler } from "../utils/asyncHandler.js";
import { scheduleService } from "../services/schedule.service.js";
import { passwordService } from "../services/password.service.js";
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
  UpdateTripBody,
  UpdateScheduleItemBody,
  CreateScheduleItemBody,
  CreateScheduleDayBody,
  UpdateScheduleDayBody,
  CreateScheduleUpdateBody,
} from "../types/index.js";

function generateId(prefix: string = ""): string {
  return prefix ? `${prefix}-${crypto.randomUUID()}` : crypto.randomUUID();
}

export const adminController = {
  getStats: asyncHandler(async (_: Request, res: Response) => {
    const [destinations, hotels, flights, tours, tripsUpcoming, tripsHistory] = await Promise.all([
      prisma.destination.count(),
      prisma.hotel.count(),
      prisma.flight.count(),
      prisma.tourPackage.count(),
      prisma.trip.count({ where: { isUpcoming: true } }),
      prisma.trip.count({ where: { isUpcoming: false } }),
    ]);
    res.json({ destinations, hotels, flights, tours, tripsUpcoming, tripsHistory });
  }),

  // --- Destinations ---
  getDestinations: asyncHandler(async (_: Request, res: Response) => {
    const data = await prisma.destination.findMany({ orderBy: { name: "asc" } });
    res.json(data);
  }),

  createDestination: asyncHandler(async (req: Request, res: Response) => {
    const body = req.body as CreateDestinationBody;
    const dest = await prisma.destination.create({
      data: {
        id: body.id || generateId("dest"),
        name: body.name, location: body.location,
        category: body.category || "Địa điểm",
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
    const dest = await prisma.destination.update({
      where: { id: req.params.id as string },
      data: { 
        name: body.name, location: body.location, category: body.category, 
        rating: body.rating, duration: body.duration, imagePath: body.imagePath, 
        description: body.description, price: body.price, reviewsCount: body.reviewsCount, 
        isFavorite: body.isFavorite, isRecommended: body.isRecommended, 
        latitude: body.latitude, longitude: body.longitude 
      },
    });
    res.json(dest);
  }),

  deleteDestination: asyncHandler(async (req: Request, res: Response) => {
    await prisma.destination.delete({ where: { id: req.params.id as string } });
    res.json({ ok: true });
  }),

  // --- Hotels ---
  getHotels: asyncHandler(async (_: Request, res: Response) => {
    const data = await prisma.hotel.findMany({ include: { rooms: true }, orderBy: { name: "asc" } });
    res.json(data);
  }),

  createHotel: asyncHandler(async (req: Request, res: Response) => {
    const body = req.body as CreateHotelBody;
    const hotel = await prisma.hotel.create({
      data: {
        id: body.id || generateId("hotel"),
        name: body.name, location: body.location,
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
    const hotel = await prisma.hotel.update({
      where: { id: req.params.id as string },
      data: { 
        name: body.name, location: body.location, address: body.address, 
        rating: body.rating, imagePath: body.imagePath, description: body.description, 
        priceFrom: body.priceFrom, amenities: body.amenities, 
        latitude: body.latitude, longitude: body.longitude 
      },
    });
    res.json(hotel);
  }),

  deleteHotel: asyncHandler(async (req: Request, res: Response) => {
    await prisma.room.deleteMany({ where: { hotelId: req.params.id as string } });
    await prisma.hotel.delete({ where: { id: req.params.id as string } });
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
    const flight = await prisma.flight.update({
      where: { id: req.params.id as string },
      data: { 
        airline: body.airline, airlineLogo: body.airlineLogo, departure: body.departure, 
        arrival: body.arrival, departureTime: body.departureTime, arrivalTime: body.arrivalTime, 
        price: body.price, duration: body.duration 
      },
    });
    res.json(flight);
  }),

  deleteFlight: asyncHandler(async (req: Request, res: Response) => {
    await prisma.flight.delete({ where: { id: req.params.id as string } });
    res.json({ ok: true });
  }),

  // --- Tours ---
  getTours: asyncHandler(async (_: Request, res: Response) => {
    const data = await prisma.tourPackage.findMany({ orderBy: { createdAt: "desc" } });
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
    const tour = await prisma.tourPackage.update({
      where: { id: req.params.id as string },
      data: { 
        name: body.name, description: body.description, imagePath: body.imagePath, 
        duration: body.duration, price: body.price, originalPrice: body.originalPrice, 
        destinations: body.destinations, includes: body.includes, departure: body.departure, 
        departureDate: body.departureDate ?? undefined,
        isPopular: body.isPopular, includesGuide: body.includesGuide, guideFee: body.guideFee 
      },
    });
    res.json(tour);
  }),

  deleteTour: asyncHandler(async (req: Request, res: Response) => {
    await prisma.tourPackage.delete({ where: { id: req.params.id as string } });
    res.json({ ok: true });
  }),

  // --- Trips ---
  getTrips: asyncHandler(async (_: Request, res: Response) => {
    const data = await prisma.trip.findMany({ orderBy: { createdAt: "desc" } });
    res.json(data);
  }),

  updateTrip: asyncHandler(async (req: Request, res: Response) => {
    const body = req.body as UpdateTripBody;
    const trip = await prisma.trip.update({
      where: { id: req.params.id as string },
      data: { status: body.status, isUpcoming: body.isUpcoming },
    });
    res.json(trip);
  }),

  deleteTrip: asyncHandler(async (req: Request, res: Response) => {
    await prisma.trip.delete({ where: { id: req.params.id as string } });
    res.json({ ok: true });
  }),

  getTripSchedule: asyncHandler(async (req: Request, res: Response) => {
    const tripId = req.params.id as string;
    const days = await prisma.tripScheduleDay.findMany({
      where: { tripId },
      include: {
        items: {
          orderBy: { sortOrder: "asc" }
        }
      },
      orderBy: { dayNumber: "asc" }
    });
    const updates = await prisma.tripScheduleUpdate.findMany({
      where: { tripId },
      orderBy: { createdAt: "desc" }
    });
    res.json({ days, updates });
  }),

  updateTripScheduleItem: asyncHandler(async (req: Request, res: Response) => {
    const itemId = req.params.itemId as string;
    const body = req.body as UpdateScheduleItemBody;
    const data: Record<string, any> = {};
    if (body.startTime !== undefined) data.startTime = body.startTime;
    if (body.endTime !== undefined) data.endTime = body.endTime;
    if (body.title !== undefined) data.title = body.title;
    if (body.description !== undefined) data.description = body.description;
    if (body.locationName !== undefined) data.locationName = body.locationName;
    if (body.latitude !== undefined) data.latitude = body.latitude;
    if (body.longitude !== undefined) data.longitude = body.longitude;
    if (body.sortOrder !== undefined) data.sortOrder = body.sortOrder;
    if (body.statusOverride !== undefined) data.statusOverride = body.statusOverride;
    if (body.note !== undefined) data.note = body.note;
    const item = await prisma.tripScheduleItem.update({ where: { id: itemId }, data });
    
    // Emit real-time update
    const tripDay = await prisma.tripScheduleDay.findUnique({ where: { id: item.dayId } });
    const io = req.app.get("io");
    if (io && tripDay) {
      io.to(`trip_${tripDay.tripId}`).emit("schedule_updated");
    }
    res.json(item);
  }),

  createTripScheduleUpdate: asyncHandler(async (req: Request, res: Response) => {
    const tripId = req.params.id as string;
    const body = req.body as CreateScheduleUpdateBody;
    const update = await prisma.tripScheduleUpdate.create({
      data: {
        tripId,
        message: body.message
      }
    });

    // Emit real-time update
    const io = req.app.get("io");
    if (io) {
      io.to(`trip_${tripId}`).emit("schedule_updated");
    }

    res.status(201).json(update);
  }),

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
    });
    if (!result) {
      res.status(404).json({ message: "Day not found" });
      return;
    }
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
    res.json({ ok: true });
  }),

  updateTripScheduleDay: asyncHandler(async (req: Request, res: Response) => {
    const tripId = req.params.id as string;
    const dayId = req.params.dayId as string;
    const body = req.body as UpdateScheduleDayBody;
    const day = await prisma.tripScheduleDay.findFirst({ where: { id: dayId, tripId } });
    if (!day) {
      res.status(404).json({ message: "Day not found" });
      return;
    }
    const updated = await prisma.tripScheduleDay.update({
      where: { id: dayId },
      data: { title: body.title ?? null },
    });
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
    await prisma.category.delete({ where: { id: req.params.id as string } });
    res.json({ ok: true });
  }),

  // --- Users ---
  getUsers: asyncHandler(async (_: Request, res: Response) => {
    const data = await prisma.user.findMany({ orderBy: { createdAt: "desc" }, select: { id: true, name: true, email: true, createdAt: true } });
    res.json(data);
  }),

  createUser: asyncHandler(async (req: Request, res: Response) => {
    const body = req.body as CreateUserBody;
    const password = await passwordService.hash(body.password);
    const user = await prisma.user.create({ data: { name: body.name, email: body.email, password } });
    res.status(201).json({ id: user.id, name: user.name, email: user.email });
  }),

  deleteUser: asyncHandler(async (req: Request, res: Response) => {
    await prisma.user.delete({ where: { id: req.params.id as string } });
    res.json({ ok: true });
  }),

  // --- Rooms ---
  getRooms: asyncHandler(async (req: Request, res: Response) => {
    const data = await prisma.room.findMany({ where: { hotelId: req.params.hotelId as string }, orderBy: { name: "asc" } });
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
        amenities: body.amenities || []
      }
    });
    res.status(201).json(room);
  }),

  updateRoom: asyncHandler(async (req: Request, res: Response) => {
    const body = req.body as UpdateRoomBody;
    const room = await prisma.room.update({
      where: { id: req.params.roomId as string },
      data: { name: body.name, description: body.description, price: body.price, capacity: body.capacity, imagePath: body.imagePath, amenities: body.amenities }
    });
    res.json(room);
  }),

  deleteRoom: asyncHandler(async (req: Request, res: Response) => {
    await prisma.room.delete({ where: { id: req.params.roomId as string } });
    res.json({ ok: true });
  }),

  // --- Documents ---
  getDocuments: asyncHandler(async (_: Request, res: Response) => {
    const data = await prisma.documentItem.findMany({ orderBy: { createdAt: "desc" } });
    res.json(data);
  }),

  createDocument: asyncHandler(async (req: Request, res: Response) => {
    const body = req.body as CreateDocumentBody;
    const doc = await prisma.documentItem.create({
      data: { id: body.id || generateId("doc"), title: body.title, description: body.description || "", icon: body.icon || "fa-file", color: body.color || "text-gray-500" }
    });
    res.status(201).json(doc);
  }),

  updateDocument: asyncHandler(async (req: Request, res: Response) => {
    const body = req.body as UpdateDocumentBody;
    const doc = await prisma.documentItem.update({
      where: { id: req.params.id as string },
      data: { title: body.title, description: body.description, icon: body.icon, color: body.color }
    });
    res.json(doc);
  }),

  deleteDocument: asyncHandler(async (req: Request, res: Response) => {
    await prisma.documentItem.delete({ where: { id: req.params.id as string } });
    res.json({ ok: true });
  }),
};
