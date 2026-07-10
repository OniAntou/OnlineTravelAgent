import { Prisma } from "@prisma/client";
import prisma from "../config/prisma.js";
import { attachRealReviews, generateId } from "./helpers.js";
import { TripStatus } from "@prisma/client";

export const hotelStore = {
  async getHotels(location?: string) {
    const where: Prisma.HotelWhereInput = location
      ? { location: { contains: location, mode: "insensitive" } }
      : {};
    const hotels = await prisma.hotel.findMany({ where });
    return attachRealReviews(hotels, "hotel");
  },

  async getHotelById(id: string) {
    const hotel = await prisma.hotel.findUnique({
      where: { id },
      include: { rooms: true },
    });
    if (!hotel) return null;
    const items = await attachRealReviews([hotel], "hotel");
    return items[0];
  },

  async searchHotels(query: string) {
    if (!query.trim()) return [];
    const formattedQuery = query.trim().split(/\s+/).join(" | ");
    const hotels = await prisma.hotel.findMany({
      where: {
        OR: [
          { name: { search: formattedQuery } },
          { location: { search: formattedQuery } },
          { name: { contains: query, mode: "insensitive" } },
        ],
      },
      take: 10,
    });
    return attachRealReviews(hotels, "hotel");
  },

  async bookHotel(
    userId: string | undefined,
    roomId: string,
    checkIn: string,
    checkOut: string,
    guests: string,
    requestId?: string,
  ) {
    if (requestId) {
      const existing = await prisma.trip.findUnique({ where: { requestId } });
      if (existing) return existing;
    }

    const room = await prisma.room.findUnique({
      where: { id: roomId },
      include: { hotel: true },
    });
    if (!room) {
      return null;
    }

    return prisma.trip.create({
      data: {
        id: generateId("trip-hotel"),
        userId,
        destination: room.hotel.name,
        location: room.hotel.location,
        date: `${checkIn} - ${checkOut}`,
        guests,
        status: TripStatus.ONGOING,
        imagePath: room.hotel.imagePath,
        isUpcoming: true,
        hotelId: room.hotel.id,
        roomId: room.id,
        totalPrice: room.price,
        requestId,
      },
    });
  },
};
