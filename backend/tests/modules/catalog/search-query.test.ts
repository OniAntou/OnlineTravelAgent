import { describe, expect, it } from "vitest";
import { formatSearchQuery } from "../../../src/core/data/store-helpers.js";

describe("formatSearchQuery", () => {
  it("removes PostgreSQL tsquery operators supplied by the user", () => {
    expect(formatSearchQuery("  a & (Đà | Nẵng)!  ")).toBe("a | Đà | Nẵng");
  });

  it("returns an empty query when no searchable token remains", () => {
    expect(formatSearchQuery("& | ! ()")).toBe("");
  });
});
