import { beforeEach, describe, expect, it, vi } from "vitest";

const mocks = vi.hoisted(() => ({
  queryRaw: vi.fn(),
  destinationFindUnique: vi.fn(),
  reviewUpsert: vi.fn(),
}));

vi.mock("../src/config/prisma.js", () => ({
  default: {
    $queryRaw: mocks.queryRaw,
    destination: { findUnique: mocks.destinationFindUnique },
    review: { upsert: mocks.reviewUpsert },
  },
}));

import { reviewStore } from "../src/store/review.store.js";

describe("review target validation", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mocks.queryRaw.mockResolvedValue([{ ok: 1 }]);
    mocks.destinationFindUnique.mockResolvedValue(null);
  });

  it("rejects a review for a destination that does not exist", async () => {
    await expect(
      reviewStore.createReview(
        "user-1",
        "destination",
        "missing-destination",
        5,
        "Great",
      ),
    ).rejects.toMatchObject({ statusCode: 404 });
    expect(mocks.reviewUpsert).not.toHaveBeenCalled();
  });
});
