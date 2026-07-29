import { beforeEach, describe, expect, it, vi } from "vitest";

const mocks = vi.hoisted(() => ({
  transaction: vi.fn(),
  findExistingTrip: vi.fn(),
  findTour: vi.fn(),
  createTrip: vi.fn(),
  copyTemplateToTrip: vi.fn(),
}));

const tx = {
  tourPackage: { findUnique: mocks.findTour },
  trip: {
    findFirst: mocks.findExistingTrip,
    create: mocks.createTrip,
  },
};

vi.mock("../../../src/infrastructure/database/prisma.js", () => ({
  default: {
    $transaction: mocks.transaction,
    tourPackage: { findUnique: mocks.findTour },
    trip: {
      findFirst: mocks.findExistingTrip,
      create: mocks.createTrip,
    },
  },
}));

vi.mock("../../../src/modules/trips/schedule.service.js", () => ({
  scheduleService: { copyTemplateToTrip: mocks.copyTemplateToTrip },
}));

import { tourStore } from "../../../src/modules/catalog/data/tour.store.js";

describe("tour booking store", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mocks.transaction.mockImplementation((run) => run(tx));
    mocks.findExistingTrip.mockResolvedValue(null);
    mocks.findTour.mockResolvedValue({
      id: "tour-1",
      name: "Ha Giang",
      departure: "Ha Noi",
      imagePath: "/uploads/tour.jpg",
      price: 750,
    });
    mocks.createTrip.mockResolvedValue({ id: "trip-1", userId: "user-1" });
    mocks.copyTemplateToTrip.mockResolvedValue(undefined);
  });

  it("rolls back the trip when copying its schedule fails", async () => {
    const failure = new Error("schedule copy failed");
    mocks.copyTemplateToTrip.mockRejectedValueOnce(failure);

    await expect(
      tourStore.bookTour(
        "user-1",
        "tour-1",
        "2026-08-01",
        "2",
        200,
        "request-1",
      ),
    ).rejects.toBe(failure);

    expect(mocks.transaction).toHaveBeenCalledOnce();
    expect(mocks.copyTemplateToTrip).toHaveBeenCalledWith(
      {
        tripId: "trip-1",
        sourceType: "tour",
        sourceId: "tour-1",
        tripDate: "2026-08-01",
      },
      tx,
    );
    expect(mocks.createTrip).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({ totalPrice: 750 }),
      }),
    );
  });
});
