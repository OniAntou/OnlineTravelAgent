import { Request, Response } from "express";
import crypto from "crypto";
import { ReviewTargetType } from "@prisma/client";
import { asyncHandler } from "../../core/utils/asyncHandler.js";
import prisma from "../../infrastructure/database/prisma.js";
import { deleteManagedPublicImages } from "../../core/storage/supabase-storage.js";

function replacedImagePath(previous: string, next: string | undefined): string[] {
  return next !== undefined && next !== previous ? [previous] : [];
}

export const partnerController = {
  getHotels: asyncHandler(async (req: Request, res: Response) => {
    const partnerId = (req as any).userId;
    const hotels = await prisma.hotel.findMany({
      where: { partnerId },
      include: { rooms: true },
    });
    res.json(hotels);
  }),

  getStats: asyncHandler(async (req: Request, res: Response) => {
    const partnerId = (req as any).userId;
    const hotelsCount = await prisma.hotel.count({ where: { partnerId } });
    const toursCount = await prisma.tourPackage.count({ where: { partnerId } });
    res.json({
      hotels: hotelsCount,
      tours: toursCount,
      destinations: 0,
      flights: 0,
      trips: 0,
      users: 0,
      revenue: 0,
      monthly: []
    });
  }),

  createHotel: asyncHandler(async (req: Request, res: Response) => {
    const partnerId = (req as any).userId;
    const { name, location, imagePath, description, priceFrom, address, amenities } = req.body;
    
    const hotel = await prisma.hotel.create({
      data: {
        id: `hotel-${crypto.randomUUID()}`,
        partnerId,
        name,
        location,
        rating: "0.0", // Partners cannot set their own rating
        imagePath: imagePath || "assets/images/hotel_placeholder.jpg",
        description,
        priceFrom: priceFrom || 0,
        address,
        amenities: amenities || ["Wifi", "Hồ bơi", "Nhà hàng"],
      }
    });
    res.status(201).json(hotel);
  }),

  getTours: asyncHandler(async (req: Request, res: Response) => {
    const partnerId = (req as any).userId;
    const tours = await prisma.tourPackage.findMany({ where: { partnerId } });
    res.json(tours);
  }),

  createTour: asyncHandler(async (req: Request, res: Response) => {
    const partnerId = (req as any).userId;
    const {
      name,
      description,
      duration,
      price,
      originalPrice,
      imagePath,
      destinations,
      includes,
      departure,
      departureDate,
      isPopular,
      includesGuide,
      guideFee,
    } = req.body;
    
    const tour = await prisma.tourPackage.create({
      data: {
        id: `tour-${crypto.randomUUID()}`,
        partnerId,
        name,
        description,
        duration: duration || "3N2Đ",
        price: price || 0,
        originalPrice: originalPrice ?? null,
        imagePath: imagePath || "assets/images/tour_placeholder.jpg",
        destinations: destinations || [],
        includes: includes || ["Khách sạn", "Xe đưa đón", "Ăn sáng"],
        departure: departure || "TP.HCM",
        departureDate: departureDate || null,
        isPopular: isPopular ?? false,
        includesGuide: includesGuide ?? true,
        guideFee: guideFee ?? 50,
      }
    });
    res.status(201).json(tour);
  }),

  updateHotel: asyncHandler(async (req: Request, res: Response) => {
    const partnerId = (req as any).userId;
    const id = req.params.id as string;
    const hotel = await prisma.hotel.findFirst({ where: { id, partnerId } });
    if (!hotel) return res.status(404).json({ message: "Not found or unauthorized" });
    const { id: _id, partnerId: _partnerId, rating: _rating, ...data } = req.body;
    
    const updated = await prisma.hotel.update({
      where: { id },
      data
    });
    await deleteManagedPublicImages(replacedImagePath(hotel.imagePath, data.imagePath));
    res.json(updated);
  }),

  deleteHotel: asyncHandler(async (req: Request, res: Response) => {
    const partnerId = (req as any).userId;
    const id = req.params.id as string;
    const hotel = await prisma.hotel.findFirst({ where: { id, partnerId } });
    if (!hotel) return res.status(404).json({ message: "Not found or unauthorized" });
    const rooms = await prisma.room.findMany({
      where: { hotelId: id },
      select: { imagePath: true },
    });
    
    await prisma.$transaction(async (tx) => {
      await tx.review.deleteMany({
        where: { targetType: ReviewTargetType.hotel, targetId: id },
      });
      await tx.room.deleteMany({ where: { hotelId: id } });
      await tx.hotel.delete({ where: { id } });
    });
    await deleteManagedPublicImages([
      hotel.imagePath,
      ...rooms.map((room) => room.imagePath),
    ]);
    res.json({ success: true });
  }),

  updateTour: asyncHandler(async (req: Request, res: Response) => {
    const partnerId = (req as any).userId;
    const id = req.params.id as string;
    const tour = await prisma.tourPackage.findFirst({ where: { id, partnerId } });
    if (!tour) return res.status(404).json({ message: "Not found or unauthorized" });
    const { id: _id, partnerId: _partnerId, ...data } = req.body;
    
    const updated = await prisma.tourPackage.update({
      where: { id },
      data
    });
    await deleteManagedPublicImages(replacedImagePath(tour.imagePath, data.imagePath));
    res.json(updated);
  }),

  deleteTour: asyncHandler(async (req: Request, res: Response) => {
    const partnerId = (req as any).userId;
    const id = req.params.id as string;
    const tour = await prisma.tourPackage.findFirst({ where: { id, partnerId } });
    if (!tour) return res.status(404).json({ message: "Not found or unauthorized" });
    
    await prisma.$transaction(async (tx) => {
      await tx.review.deleteMany({
        where: { targetType: ReviewTargetType.tour, targetId: id },
      });
      await tx.tourPackage.delete({ where: { id } });
    });
    await deleteManagedPublicImages([tour.imagePath]);
    res.json({ success: true });
  }),

  getRooms: asyncHandler(async (req: Request, res: Response) => {
    const partnerId = (req as any).userId;
    const hotelId = req.params.hotelId as string;
    const hotel = await prisma.hotel.findFirst({ where: { id: hotelId, partnerId } });
    if (!hotel) return res.status(404).json({ message: "Not found or unauthorized" });
    const rooms = await prisma.room.findMany({ where: { hotelId } });
    res.json(rooms);
  }),

  createRoom: asyncHandler(async (req: Request, res: Response) => {
    const partnerId = (req as any).userId;
    const hotelId = req.params.hotelId as string;
    const hotel = await prisma.hotel.findFirst({ where: { id: hotelId, partnerId } });
    if (!hotel) return res.status(404).json({ message: "Not found or unauthorized" });
    const { name, description, price, capacity, inventory, imagePath, amenities } = req.body;
    const room = await prisma.room.create({
      data: {
        id: `room-${crypto.randomUUID()}`,
        hotelId,
        name,
        description: description || "",
        price: Number(price) || 0,
        capacity: Number(capacity) || 1,
        inventory: inventory ?? 1,
        imagePath: imagePath || "",
        amenities: amenities || []
      }
    });
    res.status(201).json(room);
  }),

  updateRoom: asyncHandler(async (req: Request, res: Response) => {
    const partnerId = (req as any).userId;
    const hotelId = req.params.hotelId as string;
    const roomId = req.params.roomId as string;
    const hotel = await prisma.hotel.findFirst({ where: { id: hotelId, partnerId } });
    if (!hotel) return res.status(404).json({ message: "Not found or unauthorized" });
    const room = await prisma.room.findFirst({
      where: { id: roomId, hotelId },
      select: { imagePath: true },
    });
    
    const { name, description, price, capacity, inventory, imagePath, amenities } = req.body;
    await prisma.room.updateMany({
      where: { id: roomId, hotelId },
      data: { name, description, price: Number(price) || 0, capacity: Number(capacity) || 1, inventory, imagePath, amenities }
    });
    await deleteManagedPublicImages(replacedImagePath(room?.imagePath ?? "", imagePath));
    res.json({ success: true });
  }),

  deleteRoom: asyncHandler(async (req: Request, res: Response) => {
    const partnerId = (req as any).userId;
    const hotelId = req.params.hotelId as string;
    const roomId = req.params.roomId as string;
    const hotel = await prisma.hotel.findFirst({ where: { id: hotelId, partnerId } });
    if (!hotel) return res.status(404).json({ message: "Not found or unauthorized" });
    const room = await prisma.room.findFirst({
      where: { id: roomId, hotelId },
      select: { imagePath: true },
    });
    
    await prisma.room.deleteMany({ where: { id: roomId, hotelId } });
    await deleteManagedPublicImages([room?.imagePath ?? ""]);
    res.json({ success: true });
  })
};
