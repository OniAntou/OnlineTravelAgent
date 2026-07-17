import { beforeEach, describe, expect, it, vi } from "vitest";

const mocks = vi.hoisted(() => ({
  reviewFindMany: vi.fn(),
  reviewAggregate: vi.fn(),
}));

vi.mock("../../../src/infrastructure/database/prisma.js", () => ({
  default: {
    review: {
      findMany: mocks.reviewFindMany,
      aggregate: mocks.reviewAggregate,
    },
  },
}));

import { reviewStore } from "../../../src/modules/catalog/data/review.store.js";

describe("review pagination", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mocks.reviewFindMany.mockResolvedValue([
      { id: "review-3", rating: 5, user: { id: "user-3", name: "Three" } },
      { id: "review-2", rating: 4, user: { id: "user-2", name: "Two" } },
      { id: "review-1", rating: 3, user: { id: "user-1", name: "One" } },
    ]);
    mocks.reviewAggregate.mockResolvedValue({
      _count: { id: 3 },
      _avg: { rating: 4 },
    });
  });

  it("returns a fixed-size page and database aggregate with a stable next cursor", async () => {
    const result = await reviewStore.getReviews("hotel", "hotel-1", {
      limit: 2,
    });

    expect(mocks.reviewFindMany).toHaveBeenCalledWith(
      expect.objectContaining({
        take: 3,
        orderBy: [{ createdAt: "desc" }, { id: "desc" }],
      }),
    );
    expect(mocks.reviewAggregate).toHaveBeenCalledWith({
      where: { targetType: "hotel", targetId: "hotel-1" },
      _count: { id: true },
      _avg: { rating: true },
    });
    expect(result).toMatchObject({
      reviews: [expect.objectContaining({ id: "review-3" }), expect.objectContaining({ id: "review-2" })],
      total: 3,
      avgRating: 4,
      nextCursor: "review-2",
    });
  });
});
