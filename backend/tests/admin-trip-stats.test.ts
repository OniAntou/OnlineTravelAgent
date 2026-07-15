import request from "supertest";
import { beforeEach, describe, expect, it, vi } from "vitest";

const mocks = vi.hoisted(() => ({
  destinationCount: vi.fn(),
  hotelCount: vi.fn(),
  flightCount: vi.fn(),
  tourCount: vi.fn(),
  tripFindMany: vi.fn(),
}));

vi.mock("../src/config/prisma.js", () => ({
  default: {
    destination: { count: mocks.destinationCount },
    hotel: { count: mocks.hotelCount },
    flight: { count: mocks.flightCount },
    tourPackage: { count: mocks.tourCount },
    trip: { findMany: mocks.tripFindMany },
  },
}));

import { app } from "../src/app.js";
import { env } from "../src/config/env.js";

const adminAuth = `Basic ${Buffer.from(`admin:${env.adminPassword}`).toString("base64")}`;

describe("admin trip statistics", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mocks.destinationCount.mockResolvedValue(1);
    mocks.hotelCount.mockResolvedValue(1);
    mocks.flightCount.mockResolvedValue(1);
    mocks.tourCount.mockResolvedValue(1);
    mocks.tripFindMany.mockResolvedValue([
      { date: "2099-01-01", status: "ONGOING", isUpcoming: false },
      { date: "2000-01-01", status: "ONGOING", isUpcoming: true },
    ]);
  });

  it("counts trips from derived chronology instead of stale flags", async () => {
    const response = await request(app)
      .get("/api/admin/stats")
      .set("Authorization", adminAuth);

    expect(response.status).toBe(200);
    expect(response.body).toMatchObject({ tripsUpcoming: 1, tripsHistory: 1 });
    expect(mocks.tripFindMany).toHaveBeenCalledOnce();
  });
});
