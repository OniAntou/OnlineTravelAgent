import { beforeEach, describe, expect, it, vi } from "vitest";

const mocks = vi.hoisted(() => ({
  categoryFindMany: vi.fn(),
  destinationFindMany: vi.fn(),
  hotelFindMany: vi.fn(),
  tourPackageFindMany: vi.fn(),
  flightFindMany: vi.fn(),
  reviewGroupBy: vi.fn(),
}));

vi.mock("../src/infrastructure/database/prisma.js", () => ({
  default: {
    category: { findMany: mocks.categoryFindMany },
    destination: { findMany: mocks.destinationFindMany },
    hotel: { findMany: mocks.hotelFindMany },
    tourPackage: { findMany: mocks.tourPackageFindMany },
    flight: { findMany: mocks.flightFindMany },
    review: { groupBy: mocks.reviewGroupBy },
  },
}));

import { appCache } from "../src/core/config/cache.js";
import { bootstrapStore } from "../src/store/bootstrap.store.js";

describe("bootstrap hotel data", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    appCache.flushAll();

    const hotel = {
      id: "hotel-1",
      name: "Hotel with rooms",
      location: "Da Nang",
      rating: "4.5",
      imagePath: "hotel.jpg",
      description: "A bookable hotel",
      priceFrom: 500000,
      address: "1 Beach Road",
      amenities: [],
      updatedAt: new Date(),
    };
    const room = {
      id: "room-1",
      hotelId: "hotel-1",
      name: "Deluxe room",
      description: "Sea view",
      price: 700000,
      capacity: 2,
      imagePath: "room.jpg",
      amenities: [],
      updatedAt: new Date(),
    };

    mocks.categoryFindMany.mockResolvedValue([]);
    mocks.destinationFindMany.mockResolvedValue([]);
    mocks.hotelFindMany.mockImplementation(async (args) =>
      args?.include?.rooms ? [{ ...hotel, rooms: [room] }] : [hotel],
    );
    mocks.tourPackageFindMany.mockResolvedValue([]);
    mocks.flightFindMany.mockResolvedValue([]);
    mocks.reviewGroupBy.mockResolvedValue([]);
  });

  it("returns each hotel's bookable rooms in the bootstrap payload", async () => {
    const bootstrap = await bootstrapStore.getBootstrap();

    expect(bootstrap.hotels).toEqual([
      expect.objectContaining({
        id: "hotel-1",
        rooms: [expect.objectContaining({ id: "room-1" })],
      }),
    ]);
  });
});
