import { describe, expect, it } from "vitest";

import { getTourScheduleRealtimeTarget } from "../../../src/modules/trips/schedule-realtime.js";

describe("getTourScheduleRealtimeTarget", () => {
  it("routes tour template changes to the subscribed tour room", () => {
    expect(
      getTourScheduleRealtimeTarget({
        sourceType: "tour",
        tourPackageId: "tour-42",
      }),
    ).toEqual({
      room: "tour_tour-42",
      payload: { tourId: "tour-42" },
    });
  });

  it("does not publish destination templates to a tour room", () => {
    expect(
      getTourScheduleRealtimeTarget({
        sourceType: "destination",
        tourPackageId: null,
      }),
    ).toBeNull();
  });
});
