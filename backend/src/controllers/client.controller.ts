import { Request, Response } from "express";
import { appCache } from "../config/cache.js";
import { store } from "../store.js";
import { scheduleService } from "../services/schedule.service.js";
import { asyncHandler } from "../utils/asyncHandler.js";
import {
  BookTripBody,
  BookFlightBody,
  BookHotelBody,
  BookTourBody,
  CreateDocumentBody,
  CreateReviewBody,
} from "../types/index.js";

export const clientController = {
  getBootstrap: asyncHandler(async (req: Request, res: Response) => {
    const userId = req.userId;
    const cacheKey = `bootstrap_${userId || 'public'}`;
    const cached = appCache.get(cacheKey);
    if (cached) {
      res.json(cached);
      return;
    }
    const data = await store.getBootstrap(userId);
    appCache.set(cacheKey, data);
    res.json(data);
  }),

  getFavorites: asyncHandler(async (req: Request, res: Response) => {
    const data = await store.getFavorites(req.userId);
    res.json(data);
  }),

  updateFavorite: asyncHandler(async (req: Request, res: Response) => {
    const id = req.params.id as string;
    const isFavorite = req.body?.isFavorite;
    const updated = await store.updateFavorite(req.userId, id, isFavorite);
    if (!updated) {
      res.status(404).json({ message: "Destination not found" });
      return;
    }
    res.json(updated);
  }),

  getTrips: asyncHandler(async (req: Request, res: Response) => {
    const userId = req.userId;
    const type = typeof req.query.type === "string" ? req.query.type : undefined;
    const data = await store.getTrips(userId, type);
    res.json(data);
  }),

  getTripSchedule: asyncHandler(async (req: Request, res: Response) => {
    const data = await scheduleService.getTripSchedule(req.params.id as string, req.userId);
    if (!data) {
      res.status(404).json({ message: "Trip schedule not found" });
      return;
    }
    res.json(data);
  }),

  bookTrip: asyncHandler(async (req: Request, res: Response) => {
    const userId = req.userId;
    const body = req.body as BookTripBody;
    const trip = await store.createTrip(userId, body.destinationId, String(body.date || ""), String(body.guests || ""), body.totalPrice ? Number(body.totalPrice) : undefined);
    if (!trip) {
      res.status(404).json({ message: "Destination not found" });
      return;
    }
    res.status(201).json(trip);
  }),

  searchFlights: asyncHandler(async (req: Request, res: Response) => {
    const departure = typeof req.query.departure === "string" ? req.query.departure : undefined;
    const arrival = typeof req.query.arrival === "string" ? req.query.arrival : undefined;
    const data = await store.searchFlights(departure, arrival);
    res.json(data);
  }),

  bookFlightTrip: asyncHandler(async (req: Request, res: Response) => {
    const userId = req.userId;
    const body = req.body as BookFlightBody;
    const trip = await store.bookFlightTrip(userId, body.flightId, String(body.date || ""), String(body.guests || ""));
    if (!trip) {
      res.status(404).json({ message: "Flight not found" });
      return;
    }
    res.status(201).json(trip);
  }),

  getDocuments: asyncHandler(async (req: Request, res: Response) => {
    const data = await store.getDocuments(req.userId);
    res.json(data);
  }),

  createDocument: asyncHandler(async (req: Request, res: Response) => {
    const body = req.body as CreateDocumentBody;
    const doc = await store.createDocument(
      req.userId,
      body.title,
      body.description || "",
      body.icon || "fa-file",
      body.color || "text-gray-500",
    );
    res.status(201).json(doc);
  }),

  deleteDocument: asyncHandler(async (req: Request, res: Response) => {
    const deleted = await store.deleteDocument(req.userId, req.params.id as string);
    if (!deleted) {
      res.status(404).json({ message: "Document not found" });
      return;
    }
    res.json({ ok: true });
  }),

  // --- Reviews ---
  getReviews: asyncHandler(async (req: Request, res: Response) => {
    const targetType = req.query.targetType as string;
    const targetId = req.query.targetId as string;
    if (!targetType || !targetId) {
      res.status(400).json({ message: "targetType and targetId are required" });
      return;
    }
    const data = await store.getReviews(targetType, targetId);
    res.json(data);
  }),

  createReview: asyncHandler(async (req: Request, res: Response) => {
    const userId = req.userId;
    const { targetType, targetId, rating, comment } = req.body as CreateReviewBody;
    const review = await store.createReview(userId, targetType, targetId, rating, comment);
    res.status(201).json(review);
  }),

  deleteReview: asyncHandler(async (req: Request, res: Response) => {
    const userId = req.userId;
    const result = await store.deleteReview(userId, req.params.id as string);
    if (!result) {
      res.status(404).json({ message: "Review not found" });
      return;
    }
    res.json({ ok: true });
  }),

  getHotels: asyncHandler(async (req: Request, res: Response) => {
    const location = typeof req.query.location === "string" ? req.query.location : undefined;
    const data = await store.getHotels(location);
    res.json(data);
  }),

  searchHotels: asyncHandler(async (req: Request, res: Response) => {
    const q = typeof req.query.q === "string" ? req.query.q : "";
    const data = await store.searchHotels(q);
    res.json(data);
  }),

  getHotelById: asyncHandler(async (req: Request, res: Response) => {
    const data = await store.getHotelById(req.params.id as string);
    if (!data) {
      res.status(404).json({ message: "Hotel not found" });
      return;
    }
    res.json(data);
  }),

  bookHotel: asyncHandler(async (req: Request, res: Response) => {
    const userId = req.userId;
    const body = req.body as BookHotelBody;
    const trip = await store.bookHotel(userId, body.roomId, body.checkIn, body.checkOut, String(body.guests || ""));
    if (!trip) {
      res.status(404).json({ message: "Room not found" });
      return;
    }
    res.status(201).json(trip);
  }),

  getTours: asyncHandler(async (req: Request, res: Response) => {
    const data = await store.getTours();
    res.json(data);
  }),

  getTourById: asyncHandler(async (req: Request, res: Response) => {
    const data = await store.getTourById(req.params.id as string);
    if (!data) {
      res.status(404).json({ message: "Tour not found" });
      return;
    }
    res.json(data);
  }),

  getTourSchedule: asyncHandler(async (req: Request, res: Response) => {
    const data = await store.getTourSchedule(req.params.id as string);
    if (!data) {
      res.status(404).json({ message: "Tour schedule not found" });
      return;
    }
    res.json(data);
  }),

  bookTour: asyncHandler(async (req: Request, res: Response) => {
    const userId = req.userId;
    const body = req.body as BookTourBody;
    const trip = await store.bookTour(userId, body.tourId, body.date, String(body.guests || ""), body.totalPrice ? Number(body.totalPrice) : undefined);
    if (!trip) {
      res.status(404).json({ message: "Tour not found" });
      return;
    }
    res.status(201).json(trip);
  }),

  createCustomTour: asyncHandler(async (req: Request, res: Response) => {
    const userId = req.userId;
    const body = req.body as BookTourBody & { destination?: string; location?: string; imagePath?: string };
    try {
      const trip = await store.createCustomTour(userId, {
        destinations: [],
        date: body.date || "",
        guests: String(body.guests || ""),
        location: body.location || "",
        imagePath: body.imagePath || "",
        totalPrice: body.totalPrice ? Number(body.totalPrice) : undefined
      });
      res.status(201).json(trip);
    } catch (error) {
      res.status(500).json({ message: "Failed to create custom tour" });
    }
  }),

  checkPromoCode: asyncHandler(async (req: Request, res: Response) => {
    const code = req.query.code as string;
    if (!code) {
      res.status(400).json({ message: "Code is required" });
      return;
    }
    const result = await store.checkPromoCode(code);
    if (result.error) {
      res.status(400).json({ message: result.error });
      return;
    }
    res.json(result.promo);
  }),

  cancelTrip: asyncHandler(async (req: Request, res: Response) => {
    const userId = req.userId;
    const tripId = req.params.id as string;
    const trip = await store.cancelTrip(userId, tripId);
    if (!trip) {
      res.status(404).json({ message: "Trip not found or unauthorized" });
      return;
    }
    res.json(trip);
  })
};
