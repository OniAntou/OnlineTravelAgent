import { readFile } from "node:fs/promises";
import { describe, expect, it } from "vitest";
import { adminTripSchema } from "../../../src/modules/admin/admin.schema.js";

describe("admin trip status contract", () => {
  it("accepts Prisma enum values and rejects localized labels", () => {
    expect(adminTripSchema.safeParse({ status: "COMPLETED" }).success).toBe(true);
    expect(adminTripSchema.safeParse({ status: "Đã đi" }).success).toBe(false);
  });

  it("uses enum values in the admin select", async () => {
    const panel = await readFile(new URL("../../../admin/index.html", import.meta.url), "utf8");
    expect(panel).toContain('<option value="ONGOING">');
    expect(panel).toContain('<option value="COMPLETED">');
    expect(panel).toContain('<option value="CANCELLED">');
  });
});
