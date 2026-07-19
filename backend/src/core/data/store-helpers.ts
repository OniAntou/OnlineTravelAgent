import crypto from "crypto";
import { ReviewTargetType } from "@prisma/client";
import prisma from "../../infrastructure/database/prisma.js";
import { assertMemoryFallbackEnabled } from "../config/data-availability.js";

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

export function parseDateOnly(value: string): Date | null {
  const normalized = value.trim();
  const vietnameseDate = /^(\d{1,2})\/(\d{1,2})\/(\d{4})$/.exec(normalized);
  const isoDate = /^(\d{4})-(\d{1,2})-(\d{1,2})$/.exec(normalized);
  const parts = vietnameseDate
    ? {
        day: Number(vietnameseDate[1]),
        month: Number(vietnameseDate[2]),
        year: Number(vietnameseDate[3]),
      }
    : isoDate
      ? {
          day: Number(isoDate[3]),
          month: Number(isoDate[2]),
          year: Number(isoDate[1]),
        }
      : null;
  if (!parts) return null;

  const date = new Date(Date.UTC(parts.year, parts.month - 1, parts.day));
  if (
    date.getUTCFullYear() !== parts.year ||
    date.getUTCMonth() !== parts.month - 1 ||
    date.getUTCDate() !== parts.day
  ) {
    return null;
  }
  return date;
}

export function formatSearchQuery(query: string): string {
  return (query.match(/[\p{L}\p{N}]+/gu) ?? []).join(" | ");
}

import { TripStatus } from "@prisma/client";

export function processTripStatus<T extends { status: TripStatus; isUpcoming: boolean; date: string }>(
  trip: T,
): T {
  if (trip.status === TripStatus.PENDING) {
    return { ...trip, isUpcoming: true };
  }

  if (trip.status === TripStatus.CANCELLED) {
    return { ...trip, isUpcoming: false };
  }

  const now = new Date();
  const today = new Date(
    Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate()),
  );
  const [startValue, endValue] = trip.date.split(/\s+-\s+/, 2);
  const start = parseDateOnly(startValue ?? "");
  const end = endValue ? parseDateOnly(endValue) : start;
  if (!start || !end || end < start) return { ...trip };

  if (today < start) {
    return { ...trip, status: TripStatus.ONGOING, isUpcoming: true };
  }
  if (today > end) {
    return { ...trip, status: TripStatus.COMPLETED, isUpcoming: false };
  }
  return { ...trip, status: TripStatus.ONGOING, isUpcoming: false };
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
  targetType: ReviewTargetType,
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
    assertMemoryFallbackEnabled();
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
