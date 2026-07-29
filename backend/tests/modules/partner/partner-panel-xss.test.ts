import { readFile } from "node:fs/promises";
import { describe, expect, it } from "vitest";

describe("partner panel rendering security", () => {
  it("escapes catalog values and encodes action arguments before inserting them into HTML", async () => {
    const panel = await readFile(
      new URL("../../../partner/scripts/app.js", import.meta.url),
      "utf8",
    );

    expect(panel).toContain("function escapeHtml(value)");
    expect(panel).toContain("function encodeActionValue(value)");
    expect(panel).toContain("c.html??escapeHtml(c.val)");
    expect(panel).toContain("document.createTextNode(String(msg ?? ''))");
  });
});
