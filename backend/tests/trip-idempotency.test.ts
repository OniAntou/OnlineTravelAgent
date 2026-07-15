import crypto from "crypto";
import { describe, expect, it } from "vitest";
import { memoryDb } from "../src/infrastructure/fallback/memory-db.js";

describe("trip idempotency fallback", () => {
  it("scopes an idempotency key to its booking owner", () => {
    const requestId = crypto.randomUUID();
    const tripId = `trip-${crypto.randomUUID()}`;

    memoryDb.createTrip({
      id: tripId,
      userId: "owner-a",
      destination: "Da Lat",
      location: "Lam Dong",
      date: "2026-08-01",
      guests: "1",
      status: "ONGOING",
      imagePath: "assets/images/dalat.jpg",
      isUpcoming: true,
      isCustom: false,
      requestId,
    });

    expect(memoryDb.findTripByRequestId("owner-a", requestId)?.id).toBe(tripId);
    expect(memoryDb.findTripByRequestId("owner-b", requestId)).toBeNull();
  });
});