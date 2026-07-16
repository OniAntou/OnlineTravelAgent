import { beforeEach, describe, expect, it, vi } from "vitest";

const mocks = vi.hoisted(() => ({
  findTrip: vi.fn(),
  findTrips: vi.fn(),
  findDays: vi.fn(),
  findUpdates: vi.fn(),
}));

vi.mock("../../../src/infrastructure/database/prisma.js", () => ({
  default: {
    trip: { findUnique: mocks.findTrip, findMany: mocks.findTrips },
    tripScheduleDay: { findMany: mocks.findDays },
    tripScheduleUpdate: { findMany: mocks.findUpdates },
  },
}));

import { scheduleService } from "../../../src/modules/trips/schedule.service.js";

describe("scheduleService.getTripSchedule", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("returns null when a client requests another user's trip schedule", async () => {
    mocks.findTrip.mockResolvedValue({ id: "trip-1", userId: "owner-1" });

    const result = await scheduleService.getTripSchedule("trip-1", "other-1");

    expect(result).toBeNull();
    expect(mocks.findDays).not.toHaveBeenCalled();
    expect(mocks.findUpdates).not.toHaveBeenCalled();
  });

  it("returns the schedule when the requester owns the trip", async () => {
    mocks.findTrip.mockResolvedValue({ id: "trip-1", userId: "owner-1" });
    mocks.findDays.mockResolvedValue([]);
    mocks.findUpdates.mockResolvedValue([]);

    const result = await scheduleService.getTripSchedule("trip-1", "owner-1");

    expect(result).toEqual({ tripId: "trip-1", days: [], updates: [] });
  });
});

describe("scheduleService.getTripSchedulesBatch", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("groups each owned trip's days and updates without repeated filtering", async () => {
    const dayOne = { id: "day-1", tripId: "trip-1", dayNumber: 1, items: [] };
    const dayTwo = { id: "day-2", tripId: "trip-2", dayNumber: 1, items: [] };
    const updateTwo = { id: "update-2", tripId: "trip-2", message: "Delayed" };
    mocks.findTrips.mockResolvedValue([{ id: "trip-1" }, { id: "trip-2" }]);
    mocks.findDays.mockResolvedValue([dayOne, dayTwo]);
    mocks.findUpdates.mockResolvedValue([updateTwo]);

    const result = await scheduleService.getTripSchedulesBatch(
      ["trip-1", "trip-2", "trip-1"],
      "owner-1",
    );

    expect(result).toEqual({
      "trip-1": { tripId: "trip-1", days: [dayOne], updates: [] },
      "trip-2": { tripId: "trip-2", days: [dayTwo], updates: [updateTwo] },
    });
    expect(mocks.findTrips).toHaveBeenCalledWith({
      where: { id: { in: ["trip-1", "trip-2"] }, userId: "owner-1" },
      select: { id: true },
    });
  });
});
