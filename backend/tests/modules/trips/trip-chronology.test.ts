import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { TripStatus } from "@prisma/client";
import { processTripStatus } from "../../../src/core/data/store-helpers.js";
import { parseTripStartDate } from "../../../src/modules/trips/schedule.service.js";

const trip = (date: string, isUpcoming = true) => ({
  id: "trip-1",
  date,
  status: TripStatus.ONGOING,
  isUpcoming,
});

describe("trip chronology", () => {
  beforeEach(() => {
    vi.useFakeTimers();
    vi.setSystemTime(new Date("2026-07-13T12:00:00Z"));
  });

  afterEach(() => vi.useRealTimers());

  it("derives future, current and past state from ISO dates", () => {
    expect(processTripStatus(trip("2026-07-14"))).toMatchObject({
      status: TripStatus.ONGOING,
      isUpcoming: true,
    });
    expect(processTripStatus(trip("2026-07-13"))).toMatchObject({
      status: TripStatus.ONGOING,
      isUpcoming: false,
    });
    expect(processTripStatus(trip("2026-07-12"))).toMatchObject({
      status: TripStatus.COMPLETED,
      isUpcoming: false,
    });
  });

  it("uses the end of a Vietnamese date range for completion", () => {
    expect(processTripStatus(trip("12/07/2026 - 14/07/2026"))).toMatchObject({
      status: TripStatus.ONGOING,
      isUpcoming: false,
    });
  });

  it("preserves stored state when a legacy date is invalid", () => {
    expect(processTripStatus(trip("not-a-date", false))).toMatchObject({
      status: TripStatus.ONGOING,
      isUpcoming: false,
    });
  });

  it("parses ISO dates when copying a schedule", () => {
    expect(parseTripStartDate("2026-08-09")?.toISOString()).toBe(
      "2026-08-09T00:00:00.000Z",
    );
  });
});
