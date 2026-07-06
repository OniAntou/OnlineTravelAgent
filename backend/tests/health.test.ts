import { describe, it, expect } from "vitest";
import request from "supertest";
import { app } from "../src/app.js";

describe("Health API", () => {
  it("should return ok: true on GET /health", async () => {
    const res = await request(app).get("/health");
    expect(res.status).toBe(200);
    expect(res.body).toEqual({ ok: true });
  });

  it("should redirect GET / to /admin", async () => {
    const res = await request(app).get("/");
    expect(res.status).toBe(302);
    expect(res.header.location).toBe("/admin");
  });

  it("should serve the admin portal", async () => {
    const res = await request(app).get("/admin/");
    expect(res.status).toBe(200);
    expect(res.text).toContain("<!DOCTYPE html>");
  });

  it("should serve the partner portal", async () => {
    const res = await request(app).get("/partner/");
    expect(res.status).toBe(200);
    expect(res.text).toContain("<!DOCTYPE html>");
  });
});
