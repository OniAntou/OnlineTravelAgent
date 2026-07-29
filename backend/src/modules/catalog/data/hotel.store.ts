import { Prisma } from "@prisma/client";
import prisma from "../../../infrastructure/database/prisma.js";
import { attachRealReviews, formatSearchQuery, generateId } from "../../../core/data/store-helpers.js";
import { TripStatus } from "@prisma/client";
import { mockHotels } from "../../../infrastructure/fallback/mock-data.js";
import { memoryDb } from "../../../infrastructure/fallback/memory-db.js";
import {
  assertMemoryFallbackEnabled,
  shouldUseMemoryFallback,
} from "../../../core/config/data-availability.js";
import {
  findIdempotentTrip,
  recoverIdempotentTrip,
} from "../../booking/data/booking-idempotency.js";
import { HttpError } from "../../../core/utils/http-error.js";

const millisecondsPerDay = 24 * 60 * 60 * 1000;

function parseBookingDate(value: string) {
  const isoMatch = /^(\d{4})-(\d{1,2})-(\d{1,2})$/.exec(value.trim());
  const vietnameseMatch = /^(\d{1,2})\/(\d{1,2})\/(\d{4})$/.exec(value.trim());
  const parts = isoMatch
    ? { year: Number(isoMatch[1]), month: Number(isoMatch[2]), day: Number(isoMatch[3]) }
    : vietnameseMatch
      ? { year: Number(vietnameseMatch[3]), month: Number(vietnameseMatch[2]), day: Number(vietnameseMatch[1]) }
      : null;

  if (!parts) return null;
  const date = new Date(Date.UTC(parts.year, parts.month - 1, parts.day));
  return date.getUTCFullYear() === parts.year
    && date.getUTCMonth() === parts.month - 1
    && date.getUTCDate() === parts.day
    ? date
    : null;
}

function parseStay(checkIn: string, checkOut: string) {
  const start = parseBookingDate(checkIn);
  const end = parseBookingDate(checkOut);
  if (!start || !end) throw new Error("Ngày nhận/trả phòng không hợp lệ");

  const nights = (end.getTime() - start.getTime()) / millisecondsPerDay;
  if (!Number.isInteger(nights) || nights < 1) {
    throw new Error("Ngày trả phòng phải sau ngày nhận phòng");
  }
  return { checkInDate: start, checkOutDate: end, nights };
}

export const hotelStore = {
  async getHotels(location?: string) {
    try {
      const where: Prisma.HotelWhereInput = location
        ? { location: { contains: location, mode: "insensitive" } }
        : {};
      const hotels = await prisma.hotel.findMany({ where });
      return attachRealReviews(hotels, "hotel");
    } catch {
      assertMemoryFallbackEnabled();
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
      assertMemoryFallbackEnabled();
      const hotel = mockHotels.find((h) => h.id === id);
      return hotel || null;
    }
  },

  async searchHotels(query: string) {
    if (!query.trim()) return [];
    try {
      const formattedQuery = formatSearchQuery(query) || "no_searchable_tokens";
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
      assertMemoryFallbackEnabled();
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
    const { checkInDate, checkOutDate, nights } = parseStay(checkIn, checkOut);
    const useMem = await shouldUseMemoryFallback();

    if (useMem) {
      if (requestId) {
        const existing = memoryDb.findTripByRequestId(userId, requestId);
        if (existing) return existing;
      }
      // Find hotel from mock data by roomId prefix
      const hotel = mockHotels.find((h) => roomId.startsWith(h.id));
      if (!hotel) return null;
      if (memoryDb.countActiveHotelStayOverlaps(roomId, checkInDate, checkOutDate) >= 1) {
        throw new HttpError(409, "Phòng không còn trống trong thời gian đã chọn");
      }
      return memoryDb.createTrip({
        id: generateId("trip-hotel"),
        userId: userId || null,
        destination: hotel.name,
        location: hotel.location,
        date: `${checkIn} - ${checkOut}`,
        guests,
        status: "PENDING",
        imagePath: hotel.imagePath,
        isUpcoming: true,
        isCustom: false,
        hotelId: hotel.id,
        roomId,
        hotelCheckIn: checkInDate,
        hotelCheckOut: checkOutDate,
        totalPrice: hotel.priceFrom * nights,
        requestId: requestId || null,
      });
    }

    if (requestId) {
      const existing = await findIdempotentTrip(prisma, userId, requestId);
      if (existing) return existing;
    }

    try {
      return await prisma.$transaction(async (tx) => {
        const lockedRooms = await tx.$queryRaw<{ id: string }[]>`
          SELECT "id" FROM "rooms" WHERE "id" = ${roomId} FOR UPDATE
        `;
        if (!lockedRooms.length) return null;

        const room = await tx.room.findUnique({
          where: { id: roomId },
          include: { hotel: true },
        });
        if (!room) return null;

        const activeReservations = await tx.trip.count({
          where: {
            roomId: room.id,
            status: { not: TripStatus.CANCELLED },
            hotelCheckIn: { lt: checkOutDate },
            hotelCheckOut: { gt: checkInDate },
          },
        });
        if (activeReservations >= room.inventory) {
          throw new HttpError(409, "Phòng không còn trống trong thời gian đã chọn");
        }

        return tx.trip.create({
          data: {
            id: generateId("trip-hotel"),
            userId,
            destination: room.hotel.name,
            location: room.hotel.location,
            date: `${checkIn} - ${checkOut}`,
            guests,
            status: TripStatus.PENDING,
            imagePath: room.hotel.imagePath,
            isUpcoming: true,
            hotelId: room.hotel.id,
            roomId: room.id,
            hotelCheckIn: checkInDate,
            hotelCheckOut: checkOutDate,
            totalPrice: new Prisma.Decimal(room.price).mul(nights),
            requestId,
          },
        });
      });
    } catch (error) {
      const existing = await recoverIdempotentTrip(
        error,
        prisma,
        userId,
        requestId,
      );
      if (existing) return existing;
      throw error;
    }
  },
};
