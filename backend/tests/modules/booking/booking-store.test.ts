import { beforeEach, describe, expect, it, vi } from "vitest";

const mocks = vi.hoisted(() => ({
  queryRaw: vi.fn(),
  transaction: vi.fn(),
  findExistingTrip: vi.fn(),
  findDestination: vi.fn(),
  createTrip: vi.fn(),
  copyTemplateToTrip: vi.fn(),
}));

const tx = {
  destination: { findUnique: mocks.findDestination },
  trip: {
    findFirst: mocks.findExistingTrip,
    create: mocks.createTrip,
  },
};

vi.mock("../../../src/infrastructure/database/prisma.js", () => ({
  default: {
    $queryRaw: mocks.queryRaw,
    $transaction: mocks.transaction,
    destination: { findUnique: mocks.findDestination },
    trip: {
      findFirst: mocks.findExistingTrip,
      create: mocks.createTrip,
    },
  },
}));

vi.mock("../../../src/modules/trips/schedule.service.js", () => ({
  scheduleService: { copyTemplateToTrip: mocks.copyTemplateToTrip },
}));

import { tripStore } from "../../../src/modules/trips/data/trip.store.js";

describe("destination booking store", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mocks.queryRaw.mockResolvedValue([{ ok: 1 }]);
    mocks.transaction.mockImplementation((run) => run(tx));
    mocks.findExistingTrip.mockResolvedValue(null);
    mocks.findDestination.mockResolvedValue({
      id: "dest-1",
      name: "Da Lat",
      location: "Lam Dong",
      imagePath: "/uploads/dalat.jpg",
      price: 900,
    });
    mocks.createTrip.mockResolvedValue({
      id: "trip-1",
      userId: "user-1",
      destinationId: "dest-1",
      requestId: "request-1",
    });
    mocks.copyTemplateToTrip.mockResolvedValue(undefined);
  });

  it("creates the trip and destination schedule in the same transaction", async () => {
    const result = await tripStore.createTrip(
      "user-1",
      "dest-1",
      "2026-08-01",
      "2",
      100,
      "request-1",
    );

    expect(result).toMatchObject({ id: "trip-1" });
    expect(mocks.transaction).toHaveBeenCalledOnce();
    expect(mocks.copyTemplateToTrip).toHaveBeenCalledWith(
      {
        tripId: "trip-1",
        sourceType: "destination",
        sourceId: "dest-1",
        tripDate: "2026-08-01",
      },
      tx,
    );
    expect(mocks.createTrip).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({ totalPrice: 900 }),
      }),
    );
  });

  it("returns the winning trip when a concurrent idempotent create hits P2002", async () => {
    const winner = { id: "trip-winner", userId: "user-1", requestId: "request-1" };
    mocks.createTrip.mockRejectedValueOnce({ code: "P2002", meta: { target: ["user_id", "request_id"] } });
    mocks.findExistingTrip
      .mockResolvedValueOnce(null)
      .mockResolvedValueOnce(winner);

    const result = await tripStore.createTrip(
      "user-1",
      "dest-1",
      "2026-08-01",
      "2",
      100,
      "request-1",
    );

    expect(result).toBe(winner);
  });
});
