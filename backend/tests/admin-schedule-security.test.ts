import request from "supertest";
import { beforeEach, describe, expect, it, vi } from "vitest";

const mocks = vi.hoisted(() => ({
  tripScheduleItemFindFirst: vi.fn(),
  tripScheduleItemUpdate: vi.fn(),
  tripScheduleDayFindFirst: vi.fn(),
  tripScheduleDayFindUnique: vi.fn(),
}));

vi.mock("../src/config/prisma.js", () => ({
  default: {
    tripScheduleItem: {
      findFirst: mocks.tripScheduleItemFindFirst,
      update: mocks.tripScheduleItemUpdate,
    },
    tripScheduleDay: {
      findFirst: mocks.tripScheduleDayFindFirst,
      findUnique: mocks.tripScheduleDayFindUnique,
    },
  },
}));

import { app } from "../src/app.js";

import { env } from "../src/config/env.js";

const adminAuth = `Basic ${Buffer.from(`admin:${env.adminPassword}`).toString("base64")}`;

describe("admin schedule security", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("rejects updating a schedule item that does not belong to the trip", async () => {
    mocks.tripScheduleItemFindFirst.mockResolvedValue(null);

    const res = await request(app)
      .put("/api/admin/trips/trip-1/schedule/items/item-1")
      .set("Authorization", adminAuth)
      .send({ dayId: "day-other", startTime: "08:00", title: "Updated" });

    expect(res.status).toBe(404);
    expect(mocks.tripScheduleItemUpdate).not.toHaveBeenCalled();
  });

  it("accepts supported schedule override statuses", async () => {
    mocks.tripScheduleItemFindFirst.mockResolvedValue({ id: "item-1" });
    mocks.tripScheduleItemUpdate.mockResolvedValue({
      id: "item-1",
      statusOverride: "delayed",
    });

    const res = await request(app)
      .put("/api/admin/trips/trip-1/schedule/items/item-1")
      .set("Authorization", adminAuth)
      .send({ statusOverride: "delayed" });

    expect(res.status).toBe(200);
    expect(mocks.tripScheduleItemUpdate).toHaveBeenCalledWith({
      where: { id: "item-1" },
      data: { statusOverride: "delayed" },
    });
  });

  it("rejects empty schedule update messages", async () => {
    const res = await request(app)
      .post("/api/admin/trips/trip-1/schedule/updates")
      .set("Authorization", adminAuth)
      .send({ message: "   " });

    expect(res.status).toBe(400);
    expect(res.body.message).toBe("message is required");
  });
});
