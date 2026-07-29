import { beforeEach, describe, expect, it, vi } from "vitest";

const mocks = vi.hoisted(() => ({
  queryRaw: vi.fn(),
  findExistingTrip: vi.fn(),
  findFlight: vi.fn(),
  createTrip: vi.fn(),
}));

vi.mock("../../../src/infrastructure/database/prisma.js", () => ({
  default: {
    $queryRaw: mocks.queryRaw,
    flight: { findUnique: mocks.findFlight },
    trip: { findFirst: mocks.findExistingTrip, create: mocks.createTrip },
  },
}));

import { tripStore } from "../../../src/modules/trips/data/trip.store.js";

describe("flight booking store", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mocks.queryRaw.mockResolvedValue([{ ok: 1 }]);
    mocks.findExistingTrip.mockResolvedValue(null);
    mocks.findFlight.mockResolvedValue({
      id: "flight-1",
      airline: "OTA Air",
      departure: "Ha Noi",
      arrival: "Da Nang",
      airlineLogo: "/uploads/ota-air.png",
      price: 420,
    });
    mocks.createTrip.mockResolvedValue({ id: "trip-flight-1" });
  });

  it("snapshots the catalogue flight price instead of leaving payment total empty", async () => {
    await tripStore.bookFlightTrip(
      "user-1",
      "flight-1",
      "2026-08-01",
      "1",
      "request-1",
    );

    expect(mocks.createTrip).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({ totalPrice: 420 }),
      }),
    );
  });
});
