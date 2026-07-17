import request from "supertest";
import { describe, expect, it } from "vitest";
import { app } from "../../src/app.js";

describe("admin panel API origin", () => {
  it("calls the API on the same origin that serves the panel", async () => {
    const response = await request(app).get("/admin/");

    expect(response.status).toBe(200);
    expect(response.text).toContain("const API=window.location.origin;");
    expect(response.text).not.toContain("const API='http://localhost:3000';");
  });

  it("uses a category selector instead of free-text destination categories", async () => {
    const response = await request(app).get("/admin/");

    expect(response.status).toBe(200);
    expect(response.text).toContain('<select class="w-full bg-white border border-silver rounded-xl px-6 py-4 text-sm font-semibold outline-none focus:border-primary" id="ds-cat">');
  });

  it("includes the Partner administration page and modal", async () => {
    const response = await request(app).get("/admin/");

    expect(response.status).toBe(200);
    expect(response.text).toContain('id="nav-partners"');
    expect(response.text).toContain('id="page-partners"');
    expect(response.text).toContain('id="modal-partner"');
  });
});
