import crypto from "crypto";
import { Prisma } from "@prisma/client";
import prisma from "./config/prisma.js";
import { scheduleService } from "./services/schedule.service.js";

function generateId(prefix: string = ""): string {
  return prefix ? `${prefix}-${crypto.randomUUID()}` : crypto.randomUUID();
}

const categoryDisplayOrder = [
  "Tất cả",
  "Địa điểm",
  "Khách sạn",
  "Máy bay",
  "Ẩm thực",
];

const hiddenCategoryNames = new Set(["Bãi biển"]);

function normalizeCategoryName(category: string): string {
  return category === "Bãi biển" ? "Địa điểm" : category;
}

function orderCategoryNames(categories: Array<{ name: string }>): string[] {
  const names = categories
    .map((category) => normalizeCategoryName(category.name))
    .filter((name) => !hiddenCategoryNames.has(name));
  const remaining = new Set(names);

  return [
    ...categoryDisplayOrder.filter((name) => {
      if (!remaining.has(name)) {
        return false;
      }
      remaining.delete(name);
      return true;
    }),
    ...names.filter((name) => remaining.delete(name)),
  ];
}

function parseDateStr(dateStr: string) {
  const parts = dateStr.split('/');
  if (parts.length === 3) {
    return new Date(parseInt(parts[2], 10), parseInt(parts[1], 10) - 1, parseInt(parts[0], 10));
  }
  return new Date();
}

function processTripStatus<T extends { status: string; isUpcoming: boolean; date: string }>(trip: T): T {
  if (trip.status === "Chờ thanh toán") return trip;

  const now = new Date();
  const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());

  try {
    let isOngoing = false;
    let isHistory = false;

    if (trip.date.includes(" - ")) {
      const [startStr, endStr] = trip.date.split(" - ");
      const start = parseDateStr(startStr.trim());
      const end = parseDateStr(endStr.trim());
      
      if (today >= start && today <= end) isOngoing = true;
      if (today > end) isHistory = true;
    } else {
      const date = parseDateStr(trip.date.trim());
      if (today.getTime() === date.getTime()) isOngoing = true;
      if (today > date) isHistory = true;
    }

    if (isOngoing) {
      trip.status = "Đang diễn ra";
      trip.isUpcoming = false;
    } else if (isHistory) {
      trip.status = "Đã hoàn thành";
      trip.isUpcoming = false;
    } else {
      trip.isUpcoming = true;
      if (trip.status === "Đang diễn ra" || trip.status === "Đã hoàn thành") {
        trip.status = "Sắp tới";
      }
    }
  } catch (e) {
    // ignore
  }
  return trip;
}

async function attachRealReviews<T extends { id: string }>(items: T[], targetType: string) {
  if (!items.length) return items;

  const ids = items.map((i) => i.id);
  const stats = await prisma.review.groupBy({
    by: ['targetId'],
    where: { targetType, targetId: { in: ids } },
    _avg: { rating: true },
    _count: { id: true },
  });

  return items.map((item) => {
    const stat = stats.find((s) => s.targetId === item.id);
    if (stat && stat._count.id > 0) {
      const count = stat._count.id;
      const avg = stat._avg.rating || 0;
      return {
        ...item,
        rating: (Math.round(avg * 10) / 10).toString(),
        reviewsCount: count > 999 ? (count / 1000).toFixed(1) + 'k' : count.toString(),
      };
    }
    return {
      ...item,
      rating: "0.0",
      reviewsCount: "0",
    };
  });
}

export const store = {
  async getBootstrap(userId?: string) {
    const [categories, destinations, trips, documents, hotels, tourPackages] = await Promise.all([
      prisma.category.findMany({ orderBy: { name: "asc" } }),
      prisma.destination.findMany(),
      userId ? prisma.trip.findMany({ where: { userId }, orderBy: { createdAt: "desc" } }) : Promise.resolve([]),
      prisma.documentItem.findMany({ orderBy: { createdAt: "desc" } }),
      prisma.hotel.findMany(),
      prisma.tourPackage.findMany({ orderBy: { createdAt: "desc" } }),
    ]);

    const normalizedDestinations = destinations.map((destination) => ({
      ...destination,
      category: normalizeCategoryName(destination.category),
    }));
    const [realDestinations, realHotels, realTours] = await Promise.all([
      attachRealReviews(normalizedDestinations, "destination"),
      attachRealReviews(hotels, "hotel"),
      attachRealReviews(tourPackages, "tour")
    ]);

    const realRecommended = realDestinations.filter((d) => d.isRecommended);

    return {
      categories: orderCategoryNames(categories),
      destinations: realDestinations,
      recommended: realRecommended,
      trips: trips.map(processTripStatus),
      documents,
      hotels: realHotels,
      tourPackages: realTours,
    };
  },

  async getHotels(location?: string) {
    const where: Prisma.HotelWhereInput = location ? { location: { contains: location, mode: "insensitive" } } : {};
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
    const hotels = await prisma.hotel.findMany({
      where: {
        OR: [
          { name: { contains: query, mode: "insensitive" } },
          { location: { contains: query, mode: "insensitive" } },
        ],
      },
    });
    return attachRealReviews(hotels, "hotel");
  },

  async bookHotel(userId: string | undefined, roomId: string, checkIn: string, checkOut: string, guests: string) {
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
        status: "Sắp tới",
        imagePath: room.hotel.imagePath,
        isUpcoming: true,
      },
    });
  },

  async getTours() {
    const tours = await prisma.tourPackage.findMany({ orderBy: { createdAt: "desc" } });
    return attachRealReviews(tours, "tour");
  },

  async getTourById(id: string) {
    const tour = await prisma.tourPackage.findUnique({ where: { id } });
    if (!tour) return null;
    const items = await attachRealReviews([tour], "tour");
    return items[0];
  },

  async getTourSchedule(tourId: string) {
    return prisma.scheduleTemplate.findFirst({
      where: { tourPackageId: tourId },
      include: {
        days: {
          include: { items: { orderBy: { sortOrder: 'asc' } } },
          orderBy: { dayNumber: 'asc' }
        }
      }
    });
  },

  async bookTour(userId: string | undefined, tourId: string, date: string, guests: string, totalPrice?: number) {
    const tour = await prisma.tourPackage.findUnique({ where: { id: tourId } });
    if (!tour) return null;

    const tripId = generateId("trip-tour");
    const trip = await prisma.trip.create({
      data: {
        id: tripId,
        userId,
        destination: tour.name,
        location: tour.departure,
        date,
        guests,
        status: "Đã xác nhận",
        imagePath: tour.imagePath,
        isUpcoming: true,
        totalPrice: totalPrice,
      },
    });

    try {
      await scheduleService.copyTemplateToTrip({
        tripId: trip.id,
        sourceType: "tour",
        sourceId: tour.id,
        tripDate: date,
      });
    } catch (e) {
      console.error("Failed to copy schedule template to trip", e);
    }

    return trip;
  },

  async cancelTrip(userId: string | undefined, tripId: string) {
    const trip = await prisma.trip.findUnique({ where: { id: tripId } });
    if (!trip || (userId && trip.userId !== userId)) {
      return null;
    }

    return prisma.trip.update({
      where: { id: tripId },
      data: {
        status: "Đã hủy",
        isUpcoming: false,
      },
    });
  },


  async createCustomTour(userId: string | undefined, data: { destinations: string[]; date: string; guests: string; location: string; imagePath: string; totalPrice?: number }) {
    const tripId = generateId("trip-custom");
    const trip = await prisma.trip.create({
      data: {
        id: tripId,
        userId,
        destination: "Tour thiết kế riêng",
        location: data.location,
        date: data.date,
        guests: data.guests,
        status: "Chờ thanh toán",
        imagePath: data.imagePath,
        isUpcoming: true,
        totalPrice: data.totalPrice,
        isCustom: true,
      },
    });

    return trip;
  },

  async getFavorites() {
    const favs = await prisma.destination.findMany({ where: { isFavorite: true } });
    return attachRealReviews(favs, "destination");
  },

  async updateFavorite(destinationId: string, isFavorite?: boolean) {
    const destination = await prisma.destination.findUnique({ where: { id: destinationId } });
    if (!destination) {
      return null;
    }

    const newFavorite = typeof isFavorite === "boolean" ? isFavorite : !destination.isFavorite;

    return prisma.destination.update({
      where: { id: destinationId },
      data: { isFavorite: newFavorite },
    });
  },

  async createTrip(userId: string | undefined, destinationId: string, date: string, guests: string, totalPrice?: number) {
    const destination = await prisma.destination.findUnique({ where: { id: destinationId } });
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
        status: "Đã xác nhận",
        imagePath: destination.imagePath,
        isUpcoming: true,
        totalPrice: totalPrice,
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

  async bookFlightTrip(userId: string | undefined, flightId: string, date: string, guests: string) {
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
        status: "Sắp tới",
        imagePath: flight.airlineLogo,
        isUpcoming: true,
      },
    });
  },

  async getTrips(userId: string | undefined, type?: string) {
    const where: Prisma.TripWhereInput = userId ? { userId } : {};
    if (type === "upcoming") where.isUpcoming = true;
    if (type === "past") where.isUpcoming = false;
    const trips = await prisma.trip.findMany({ where, orderBy: { createdAt: "desc" } });
    return trips.map(processTripStatus);
  },

  async getDocuments() {
    return prisma.documentItem.findMany({ orderBy: { createdAt: "desc" } });
  },

  async createDocument(title: string, description: string, icon: string, color: string) {
    return prisma.documentItem.create({
      data: {
        id: generateId("doc"),
        title,
        description,
        icon,
        color,
      },
    });
  },

  async deleteDocument(id: string) {
    return prisma.documentItem.delete({ where: { id } });
  },

  // --- Reviews ---
  async getReviews(targetType: string, targetId: string) {
    const reviews = await prisma.review.findMany({
      where: { targetType, targetId },
      include: { user: { select: { id: true, name: true } } },
      orderBy: { createdAt: "desc" },
    });

    const total = reviews.length;
    const avgRating = total > 0 ? reviews.reduce((sum, r) => sum + r.rating, 0) / total : 0;

    return { reviews, total, avgRating: Math.round(avgRating * 10) / 10 };
  },

  async createReview(userId: string | undefined, targetType: string, targetId: string, rating: number, comment: string) {
    if (!userId) {
      throw new Error("Authentication required to create a review");
    }
    const review = await prisma.review.create({
      data: { userId, targetType, targetId, rating, comment },
      include: { user: { select: { id: true, name: true } } },
    });
    return review;
  },

  async deleteReview(userId: string | undefined, reviewId: string) {
    const review = await prisma.review.findUnique({ where: { id: reviewId } });
    if (!review || review.userId !== userId) return null;
    await prisma.review.delete({ where: { id: reviewId } });
    return true;
  },

  // --- Promo Codes ---
  async checkPromoCode(code: string) {
    const promo = await prisma.promoCode.findUnique({ where: { code } });
    if (!promo || !promo.isActive) return { error: "Mã giảm giá không hợp lệ" };
    if (promo.validUntil && promo.validUntil < new Date()) return { error: "Mã giảm giá đã hết hạn" };
    if (promo.currentUses >= promo.maxUses) return { error: "Mã giảm giá đã hết lượt sử dụng" };
    return { promo };
  },

  async applyPromoCode(code: string) {
    await prisma.promoCode.update({
      where: { code },
      data: { currentUses: { increment: 1 } }
    });
  },
};
