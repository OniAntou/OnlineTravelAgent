import crypto from "crypto";
import prisma from "../config/prisma.js";

export function generateId(prefix: string = ""): string {
  return prefix ? `${prefix}-${crypto.randomUUID()}` : crypto.randomUUID();
}

export const categoryDisplayOrder = [
  "Tất cả",
  "Địa điểm",
  "Khách sạn",
  "Máy bay",
  "Ẩm thực",
];

export const hiddenCategoryNames = new Set(["Bãi biển"]);

export function normalizeCategoryName(category: string): string {
  return category === "Bãi biển" ? "Địa điểm" : category;
}

export function orderCategoryNames(categories: Array<{ name: string }>): string[] {
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
  const parts = dateStr.split("/");
  if (parts.length === 3) {
    return new Date(parseInt(parts[2], 10), parseInt(parts[1], 10) - 1, parseInt(parts[0], 10));
  }
  return new Date();
}

import { TripStatus } from "@prisma/client";

export function processTripStatus<T extends { status: TripStatus; isUpcoming: boolean; date: string }>(
  trip: T,
): T {
  if (trip.status === TripStatus.CANCELLED) {
    return { ...trip };
  }

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
      return { ...trip, status: TripStatus.ONGOING, isUpcoming: false };
    }
    if (isHistory) {
      return { ...trip, status: TripStatus.COMPLETED, isUpcoming: false };
    }

    return { ...trip, status: TripStatus.ONGOING, isUpcoming: true };
  } catch {
    return { ...trip };
  }
}

export async function getFavoriteDestinationIds(userId?: string) {
  if (!userId) return new Set<string>();

  const favorites = await prisma.userFavoriteDestination.findMany({
    where: { userId },
    select: { destinationId: true },
  });
  return new Set(favorites.map((favorite) => favorite.destinationId));
}

export function applyFavoriteState<T extends { id: string }>(
  items: T[],
  favoriteIds: Set<string>,
) {
  return items.map((item) => ({
    ...item,
    isFavorite: favoriteIds.has(item.id),
  }));
}

export async function attachRealReviews<T extends { id: string }>(
  items: T[],
  targetType: string,
) {
  if (!items.length) return items;

  const statsByTarget = new Map<
    string,
    { averageRating: number | null; reviewCount: number }
  >();
  try {
    const ids = items.map((i) => i.id);
    const stats = await prisma.review.groupBy({
      by: ["targetId"],
      where: { targetType, targetId: { in: ids } },
      _avg: { rating: true },
      _count: { id: true },
    });
    for (const stat of stats) {
      statsByTarget.set(stat.targetId, {
        averageRating: stat._avg.rating,
        reviewCount: stat._count.id,
      });
    }
  } catch {
    // DB unavailable — return items with their existing rating/reviewsCount or defaults
  }

  return items.map((item) => {
    const stat = statsByTarget.get(item.id);
    if (stat && stat.reviewCount > 0) {
      const count = stat.reviewCount;
      const avg = stat.averageRating || 0;
      return {
        ...item,
        rating: (Math.round(avg * 10) / 10).toString(),
        reviewsCount: count > 999 ? (count / 1000).toFixed(1) + "k" : count.toString(),
      };
    }
    return {
      ...item,
      rating: "0.0",
      reviewsCount: "0",
    };
  });
}
