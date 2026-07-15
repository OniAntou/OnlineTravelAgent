import request from "supertest";
import { beforeEach, describe, expect, it, vi } from "vitest";

const mocks = vi.hoisted(() => ({
  userCreate: vi.fn(),
  destinationDelete: vi.fn(),
}));

vi.mock("../src/infrastructure/database/prisma.js", () => ({
  default: {
    user: { create: mocks.userCreate },
    destination: { delete: mocks.destinationDelete },
  },
}));

import { app } from "../src/app.js";
import { env } from "../src/core/config/env.js";

const adminAuth = `Basic ${Buffer.from(`admin:${env.adminPassword}`).toString("base64")}`;

describe("Prisma error mapping", () => {
  beforeEach(() => vi.clearAllMocks());

  it("maps unique conflicts to HTTP 409", async () => {
    mocks.userCreate.mockRejectedValueOnce({
      code: "P2002",
      message: "Unique constraint failed",
    });

    const response = await request(app)
      .post("/api/admin/users")
      .set("Authorization", adminAuth)
      .send({
        name: "Duplicate",
        email: "duplicate@example.com",
        password: "password123",
      });

    expect(response.status).toBe(409);
  });

  it("maps missing records to HTTP 404", async () => {
    mocks.destinationDelete.mockRejectedValueOnce({
      code: "P2025",
      message: "Record not found",
    });

    const response = await request(app)
      .delete("/api/admin/destinations/missing")
      .set("Authorization", adminAuth);

    expect(response.status).toBe(404);
  });
});
