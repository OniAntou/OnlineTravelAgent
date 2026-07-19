import { readFile } from "node:fs/promises";
import { describe, expect, it } from "vitest";

describe("admin trip change request queue", () => {
  it("offers a safe, filtered review workflow", async () => {
    const panel = await readFile(
      new URL("../../../admin/index.html", import.meta.url),
      "utf8",
    );

    expect(panel).toContain('id="nav-trip-change-requests"');
    expect(panel).toContain("/api/admin/trip-change-requests");
    expect(panel).toContain('data-trip-change-request-status="PENDING"');
    expect(panel).toContain("encodeActionValue(request.id)");
    expect(panel).toContain("decodeActionValue(encodedId)");
    expect(panel).toContain("Yêu cầu hoàn tiền");
    expect(panel).toContain("Đổi lịch");
  });
});
