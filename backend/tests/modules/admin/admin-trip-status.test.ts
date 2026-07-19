import { readFile } from "node:fs/promises";
import { describe, expect, it } from "vitest";
import { TripStatus } from "@prisma/client";
import { processTripStatus } from "../../../src/core/data/store-helpers.js";
import { adminTripSchema } from "../../../src/modules/admin/admin.schema.js";

describe("admin trip status contract", () => {
  it("accepts Prisma enum values and rejects localized labels", () => {
    expect(adminTripSchema.safeParse({ status: "PENDING" }).success).toBe(true);
    expect(adminTripSchema.safeParse({ status: "COMPLETED" }).success).toBe(true);
    expect(adminTripSchema.safeParse({ status: "Đã đi" }).success).toBe(false);
  });

  it("keeps a pending booking visible for Admin attention", () => {
    expect(
      processTripStatus({
        date: "2000-01-01",
        status: "PENDING" as TripStatus,
        isUpcoming: false,
      }),
    ).toMatchObject({ status: "PENDING", isUpcoming: true });
  });

  it("uses enum values in the admin select", async () => {
    const panel = await readFile(new URL("../../../admin/index.html", import.meta.url), "utf8");
    expect(panel).toContain('id="st-pending"');
    expect(panel).toContain('data-trip-status="PENDING"');
    expect(panel).toContain('<option value="PENDING">');
    expect(panel).toContain("openPendingTrips()");
    expect(panel).toContain('<option value="ONGOING">');
    expect(panel).toContain('<option value="COMPLETED">');
    expect(panel).toContain('<option value="CANCELLED">');
  });
});
