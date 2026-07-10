import { beforeEach, describe, expect, it, vi } from "vitest";
import request from "supertest";

const mocks = vi.hoisted(() => ({ queryRaw: vi.fn() }));

vi.mock("../src/config/prisma.js", () => ({
  default: { $queryRaw: mocks.queryRaw },
}));

import { app } from "../src/app.js";

describe("Health API", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mocks.queryRaw.mockResolvedValue([{ ok: 1 }]);
  });
  it("should return ok: true on GET /health", async () => {
    const res = await request(app).get("/health");
    expect(res.status).toBe(200);
    expect(res.body).toEqual({ ok: true, db: "connected" });
  });

  it("reports service unavailable when the database is unreachable", async () => {
    mocks.queryRaw.mockRejectedValueOnce(new Error("database unavailable"));

    const res = await request(app).get("/health");

    expect(res.status).toBe(503);
    expect(res.body).toEqual({ ok: false, db: "disconnected" });
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
