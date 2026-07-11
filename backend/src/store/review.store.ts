import prisma from "../config/prisma.js";
import { memoryDb } from "./memory-db.js";
import { assertMemoryFallbackEnabled } from "../config/data-availability.js";

async function dbAvailable(): Promise<boolean> {
  try {
    await prisma.$queryRaw`SELECT 1`;
    return true;
  } catch {
    return false;
  }
}

export const reviewStore = {
  async getReviews(targetType: string, targetId: string) {
    try {
      const reviews = await prisma.review.findMany({
        where: { targetType, targetId },
        include: { user: { select: { id: true, name: true } } },
        orderBy: { createdAt: "desc" },
      });
      const total = reviews.length;
      const avgRating = total > 0 ? reviews.reduce((sum, r) => sum + r.rating, 0) / total : 0;
      return { reviews, total, avgRating: Math.round(avgRating * 10) / 10 };
    } catch {
      assertMemoryFallbackEnabled();
      const memReviews = memoryDb.findReviews(targetType, targetId);
      const total = memReviews.length;
      const avgRating = total > 0 ? memReviews.reduce((sum, r) => sum + r.rating, 0) / total : 0;
      const reviews = memReviews.map((r) => {
        const user = memoryDb.findUserById(r.userId);
        return { ...r, user: user ? { id: user.id, name: user.name } : { id: r.userId, name: "User" } };
      });
      return { reviews, total, avgRating: Math.round(avgRating * 10) / 10 };
    }
  },

  async createReview(
    userId: string | undefined,
    targetType: string,
    targetId: string,
    rating: number,
    comment: string,
  ) {
    if (!userId) throw new Error("Authentication required to create a review");

    const useMem = !(await dbAvailable());

    if (useMem) {
      assertMemoryFallbackEnabled();
      const review = memoryDb.upsertReview(userId, targetType, targetId, rating, comment);
      const user = memoryDb.findUserById(userId);
      return { ...review, user: user ? { id: user.id, name: user.name } : { id: userId, name: "User" } };
    }

    return prisma.review.upsert({
      where: { userId_targetType_targetId: { userId, targetType, targetId } },
      update: { rating, comment },
      create: { userId, targetType, targetId, rating, comment },
      include: { user: { select: { id: true, name: true } } },
    });
  },

  async deleteReview(userId: string | undefined, reviewId: string) {
    if (!userId) return null;

    const useMem = !(await dbAvailable());
    if (useMem) {
      assertMemoryFallbackEnabled();
      return memoryDb.deleteReview(userId, reviewId);
    }

    const review = await prisma.review.findUnique({ where: { id: reviewId } });
    if (!review || review.userId !== userId) return null;
    await prisma.review.delete({ where: { id: reviewId } });
    return true;
  },
};
