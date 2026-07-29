import { beforeEach, describe, expect, it, vi } from "vitest";

const mocks = vi.hoisted(() => ({
  queryRaw: vi.fn(),
  transaction: vi.fn(),
  findExistingTrip: vi.fn(),
  findRoom: vi.fn(),
  countTrips: vi.fn(),
  createTrip: vi.fn(),
}));

vi.mock("../../../src/infrastructure/database/prisma.js", () => ({
  default: {
    $queryRaw: mocks.queryRaw,
    $transaction: mocks.transaction,
    room: { findUnique: mocks.findRoom },
    trip: {
      findFirst: mocks.findExistingTrip,
      count: mocks.countTrips,
      create: mocks.createTrip,
    },
  },
}));

import { hotelStore } from "../../../src/modules/catalog/data/hotel.store.js";

describe("hotel booking store", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mocks.queryRaw.mockResolvedValue([{ ok: 1 }]);
    mocks.findExistingTrip.mockResolvedValue(null);
    mocks.findRoom.mockResolvedValue({
      id: "room-1",
      price: 120,
      inventory: 1,
      hotel: {
        id: "hotel-1",
        name: "Hotel A",
        location: "Da Nang",
        imagePath: "/uploads/hotel-a.jpg",
      },
    });
    mocks.countTrips.mockResolvedValue(0);
    mocks.createTrip.mockResolvedValue({ id: "trip-hotel-1" });
    mocks.transaction.mockImplementation(async (callback) => callback({
      $queryRaw: mocks.queryRaw,
      room: { findUnique: mocks.findRoom },
      trip: {
        count: mocks.countTrips,
        create: mocks.createTrip,
      },
    }));
  });

  it("charges every night in a validated stay instead of a single room night", async () => {
    await hotelStore.bookHotel(
      "user-1",
      "room-1",
      "2026-08-10",
      "2026-08-13",
      "2",
      "request-1",
    );

    const payload = mocks.createTrip.mock.calls[0][0];
    expect(Number(payload.data.totalPrice)).toBe(360);
    expect(payload.data.hotelCheckIn).toEqual(new Date("2026-08-10T00:00:00.000Z"));
    expect(payload.data.hotelCheckOut).toEqual(new Date("2026-08-13T00:00:00.000Z"));
    expect(mocks.transaction).toHaveBeenCalledOnce();
    expect(mocks.queryRaw).toHaveBeenLastCalledWith(expect.any(Array), "room-1");
    expect(mocks.countTrips).toHaveBeenCalledWith({
      where: {
        roomId: "room-1",
        status: { not: "CANCELLED" },
        hotelCheckIn: { lt: new Date("2026-08-13T00:00:00.000Z") },
        hotelCheckOut: { gt: new Date("2026-08-10T00:00:00.000Z") },
      },
    });
  });

  it("rejects an overlapping stay once the room type inventory is full", async () => {
    mocks.countTrips.mockResolvedValue(1);

    await expect(hotelStore.bookHotel(
      "user-1",
      "room-1",
      "2026-08-10",
      "2026-08-13",
      "2",
    )).rejects.toMatchObject({ statusCode: 409 });

    expect(mocks.createTrip).not.toHaveBeenCalled();
  });

  it("allows as many overlapping stays as configured inventory", async () => {
    mocks.findRoom.mockResolvedValue({
      id: "room-1",
      price: 120,
      inventory: 2,
      hotel: {
        id: "hotel-1",
        name: "Hotel A",
        location: "Da Nang",
        imagePath: "/uploads/hotel-a.jpg",
      },
    });
    mocks.countTrips.mockResolvedValue(1);

    await expect(hotelStore.bookHotel(
      "user-1",
      "room-1",
      "2026-08-10",
      "2026-08-13",
      "2",
    )).resolves.toEqual({ id: "trip-hotel-1" });
  });

  it("does not count a checkout on the requested check-in day as an overlap", async () => {
    await hotelStore.bookHotel(
      "user-1",
      "room-1",
      "2026-08-13",
      "2026-08-15",
      "2",
    );

    expect(mocks.countTrips).toHaveBeenCalledWith(expect.objectContaining({
      where: expect.objectContaining({
        hotelCheckIn: { lt: new Date("2026-08-15T00:00:00.000Z") },
        hotelCheckOut: { gt: new Date("2026-08-13T00:00:00.000Z") },
      }),
    }));
  });
});
