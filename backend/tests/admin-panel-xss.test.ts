import { readFile } from "node:fs/promises";
import { beforeAll, describe, expect, it } from "vitest";

type AdminRenderSecurity = {
  escapeHtml(value: unknown): string;
  safeClassNames(value: unknown): string;
  encodeActionValue(value: unknown): string;
  decodeActionValue(value: string): string;
};

declare global {
  var AdminRenderSecurity: AdminRenderSecurity;
}

describe("admin panel rendering security", () => {
  beforeAll(async () => {
    await import("../admin/render-security.js");
  });

  it("renders server-controlled text without executable markup", () => {
    const payload = `<img src=x onerror="globalThis.pwned=true">`;

    expect(globalThis.AdminRenderSecurity.escapeHtml(payload)).toBe(
      "&lt;img src=x onerror=&quot;globalThis.pwned=true&quot;&gt;",
    );
  });

  it("round-trips action values without leaving raw quotes or markup in HTML", () => {
    const payload = `');alert(1);//<img src=x onerror=alert(2)>`;
    const encoded = globalThis.AdminRenderSecurity.encodeActionValue(payload);

    expect(encoded).not.toMatch(/[<'"]/);
    expect(globalThis.AdminRenderSecurity.decodeActionValue(encoded)).toBe(payload);
  });

  it("keeps only valid CSS class tokens for trusted icon markup", () => {
    expect(
      globalThis.AdminRenderSecurity.safeClassNames(
        `fa-passport text-blue-500\" onclick=\"alert(1)`,
      ),
    ).toBe("fa-passport");
  });

  it("wires public user values through the safe render and action helpers", async () => {
    const panel = await readFile(new URL("../admin/index.html", import.meta.url), "utf8");

    expect(panel).toContain("c.html??escapeHtml(c.val)");
    expect(panel).toContain("encodeActionValue(u.name)");
    expect(panel).not.toContain("confirmDel('user','${u.id}','${u.name}')");
  });
});
