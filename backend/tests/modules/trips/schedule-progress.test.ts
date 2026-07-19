import { beforeEach, describe, expect, it, vi } from "vitest";

const mocks = vi.hoisted(() => ({
  findTrip: vi.fn(),
  findItem: vi.fn(),
  updateItem: vi.fn(),
}));

vi.mock("../../../src/infrastructure/database/prisma.js", () => ({
  default: {
    trip: { findUnique: mocks.findTrip },
    tripScheduleItem: { findFirst: mocks.findItem, update: mocks.updateItem },
  },
}));

import { scheduleService } from "../../../src/modules/trips/schedule.service.js";

describe("scheduleService.confirmTripScheduleItem", () => {
  beforeEach(() => vi.clearAllMocks());

  it("does not reveal another user's schedule item", async () => {
    mocks.findTrip.mockResolvedValue({ id: "trip-1", userId: "owner-1" });

    const result = await scheduleService.confirmTripScheduleItem(
      "trip-1",
      "item-1",
      "other-1",
    );

    expect(result).toBeNull();
    expect(mocks.findItem).not.toHaveBeenCalled();
    expect(mocks.updateItem).not.toHaveBeenCalled();
  });

  it("updates only an owned item's status to completed", async () => {
    mocks.findTrip.mockResolvedValue({ id: "trip-1", userId: "owner-1" });
    mocks.findItem.mockResolvedValue({ id: "item-1" });
    mocks.updateItem.mockResolvedValue({ id: "item-1", statusOverride: "completed" });

    const result = await scheduleService.confirmTripScheduleItem(
      "trip-1",
      "item-1",
      "owner-1",
    );

    expect(result).toEqual({ id: "item-1", statusOverride: "completed" });
    expect(mocks.findItem).toHaveBeenCalledWith({
      where: { id: "item-1", day: { tripId: "trip-1" } },
      select: { id: true },
    });
    expect(mocks.updateItem).toHaveBeenCalledWith({
      where: { id: "item-1" },
      data: { statusOverride: "completed" },
    });
  });
});
