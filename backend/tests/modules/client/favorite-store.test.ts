import { beforeEach, describe, expect, it, vi } from "vitest";

const mocks = vi.hoisted(() => ({
  destinationFindUnique: vi.fn(),
  favoriteFindUnique: vi.fn(),
  favoriteUpsert: vi.fn(),
  favoriteDeleteMany: vi.fn(),
  reviewGroupBy: vi.fn(),
}));

vi.mock("../../../src/infrastructure/database/prisma.js", () => ({
  default: {
    destination: { findUnique: mocks.destinationFindUnique },
    userFavoriteDestination: {
      findUnique: mocks.favoriteFindUnique,
      upsert: mocks.favoriteUpsert,
      deleteMany: mocks.favoriteDeleteMany,
    },
    review: { groupBy: mocks.reviewGroupBy },
  },
}));

import { bootstrapStore } from "../../../src/modules/client/data/bootstrap.store.js";

describe("favorite destinations", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mocks.destinationFindUnique.mockResolvedValue({
      id: "db-only-destination",
      name: "Destination from database",
      rating: "4.5",
      reviewsCount: "2",
    });
    mocks.favoriteFindUnique.mockResolvedValue(null);
    mocks.favoriteUpsert.mockResolvedValue({});
    mocks.reviewGroupBy.mockResolvedValue([]);
  });

  it("allows favoriting a destination that is not in the mock catalogue", async () => {
    const result = await bootstrapStore.updateFavorite(
      "user-1",
      "db-only-destination",
      true,
    );

    expect(mocks.destinationFindUnique).toHaveBeenCalledWith({
      where: { id: "db-only-destination" },
    });
    expect(mocks.favoriteUpsert).toHaveBeenCalledOnce();
    expect(result).toMatchObject({ id: "db-only-destination", isFavorite: true });
  });
});
