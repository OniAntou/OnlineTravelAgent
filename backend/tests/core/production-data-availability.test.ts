import request from "supertest";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";

const mocks = vi.hoisted(() => ({
  queryRaw: vi.fn(),
}));

vi.mock("../../src/infrastructure/database/prisma.js", () => ({
  default: {
    $queryRaw: mocks.queryRaw,
  },
}));

import { app } from "../../src/app.js";

describe("production data availability", () => {
  const originalNodeEnv = process.env.NODE_ENV;

  beforeEach(() => {
    vi.clearAllMocks();
    process.env.NODE_ENV = "production";
    mocks.queryRaw.mockRejectedValue(new Error("database unavailable"));
  });

  afterEach(() => {
    process.env.NODE_ENV = originalNodeEnv;
  });

  it("returns 503 instead of authenticating against resettable fallback data", async () => {
    const res = await request(app).post("/api/auth/login").send({
      email: "user@example.com",
      password: "password123",
    });

    expect(res.status).toBe(503);
  });
});
