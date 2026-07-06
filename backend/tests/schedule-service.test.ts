import { beforeEach, describe, expect, it, vi } from "vitest";

const mocks = vi.hoisted(() => ({
  findTrip: vi.fn(),
  findDays: vi.fn(),
  findUpdates: vi.fn(),
}));

vi.mock("../src/config/prisma.js", () => ({
  default: {
    trip: { findUnique: mocks.findTrip },
    tripScheduleDay: { findMany: mocks.findDays },
    tripScheduleUpdate: { findMany: mocks.findUpdates },
  },
}));

import { scheduleService } from "../src/services/schedule.service.js";

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
