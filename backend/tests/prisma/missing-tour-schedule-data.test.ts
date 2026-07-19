import { describe, expect, it } from "vitest";
import { missingTourScheduleTemplates } from "../../prisma/missing-tour-schedule-data.js";

const expectedDays = new Map([
  ["tour-halong-2n1d", 2],
  ["tour-ninhbinh-2n1d", 2],
  ["tour-sapa-3n2d", 3],
  ["tour-phongnha-3n2d", 3],
  ["tour-mientrung-5n4d", 5],
]);

describe("missingTourScheduleTemplates", () => {
  it("covers exactly the five tours without a template", () => {
    expect(missingTourScheduleTemplates.map((template) => template.tourPackageId))
      .toEqual([...expectedDays.keys()]);
  });

  it("has sequential days with two or three ordered activities", () => {
    for (const template of missingTourScheduleTemplates) {
      expect(template.days).toHaveLength(expectedDays.get(template.tourPackageId)!);
      expect(template.days.map((day) => day.dayNumber))
        .toEqual(Array.from({ length: template.days.length }, (_, index) => index + 1));

      for (const day of template.days) {
        expect(day.items.length).toBeGreaterThanOrEqual(2);
        expect(day.items.length).toBeLessThanOrEqual(3);
        expect(day.items.map((item) => item.startTime))
          .toEqual([...day.items.map((item) => item.startTime)].sort());
        expect(day.items.every((item) => (
          /^([01]\d|2[0-3]):[0-5]\d$/.test(item.startTime)
          && /^([01]\d|2[0-3]):[0-5]\d$/.test(item.endTime)
          && item.endTime > item.startTime
        ))).toBe(true);
      }
    }
  });
});
