import { Prisma } from "@prisma/client";
import prisma from "../config/prisma.js";
import { attachRealReviews, generateId } from "./helpers.js";
import { TripStatus } from "@prisma/client";
import { mockHotels } from "../data/mock-data.js";
import { memoryDb } from "./memory-db.js";

export const hotelStore = {
  async getHotels(location?: string) {
    try {
      const where: Prisma.HotelWhereInput = location
        ? { location: { contains: location, mode: "insensitive" } }
        : {};
      const hotels = await prisma.hotel.findMany({ where });
      return attachRealReviews(hotels, "hotel");
    } catch {
      const filtered = location
        ? mockHotels.filter((h) => h.location.toLowerCase().includes(location.toLowerCase()))
        : mockHotels;
      return filtered;
    }
  },

  async getHotelById(id: string) {
    try {
      const hotel = await prisma.hotel.findUnique({
        where: { id },
        include: { rooms: true },
      });
      if (!hotel) return null;
      const items = await attachRealReviews([hotel], "hotel");
      return items[0];
    } catch {
      const hotel = mockHotels.find((h) => h.id === id);
      return hotel || null;
    }
  },

  async searchHotels(query: string) {
    if (!query.trim()) return [];
    try {
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
    } catch {
      const q = query.toLowerCase();
      return mockHotels.filter(
        (h) => h.name.toLowerCase().includes(q) || h.location.toLowerCase().includes(q),
      );
    }
  },

  async bookHotel(
    userId: string | undefined,
    roomId: string,
    checkIn: string,
    checkOut: string,
    guests: string,
    requestId?: string,
  ) {
    const useMem = !(await prisma.$queryRaw`SELECT 1`.then(() => true).catch(() => false));

    if (useMem) {
      if (requestId) {
        const existing = memoryDb.findTripByRequestId(requestId);
        if (existing) return existing;
      }
      // Find hotel from mock data by roomId prefix
      const hotel = mockHotels.find((h) => roomId.startsWith(h.id));
      if (!hotel) return null;
      return memoryDb.createTrip({
        id: generateId("trip-hotel"),
        userId: userId || null,
        destination: hotel.name,
        location: hotel.location,
        date: `${checkIn} - ${checkOut}`,
        guests,
        status: "ONGOING",
        imagePath: hotel.imagePath,
        isUpcoming: true,
        isCustom: false,
        requestId: requestId || null,
      });
    }

    if (requestId) {
      const existing = await prisma.trip.findUnique({ where: { requestId } });
      if (existing) return existing;
    }

    const room = await prisma.room.findUnique({
      where: { id: roomId },
      include: { hotel: true },
    });
    if (!room) return null;

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
