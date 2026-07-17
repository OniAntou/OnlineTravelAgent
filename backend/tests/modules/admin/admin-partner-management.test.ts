import request from "supertest";
import { beforeEach, describe, expect, it, vi } from "vitest";

const mocks = vi.hoisted(() => ({
  userFindMany: vi.fn(),
  userCreate: vi.fn(),
  passwordHash: vi.fn(),
}));

vi.mock("../../../src/infrastructure/database/prisma.js", () => ({
  default: {
    user: { findMany: mocks.userFindMany, create: mocks.userCreate },
  },
}));

vi.mock("../../../src/modules/auth/password.service.js", () => ({
  passwordService: { hash: mocks.passwordHash },
}));

import { app } from "../../../src/app.js";
import { env } from "../../../src/core/config/env.js";

const adminAuth = `Basic ${Buffer.from(`admin:${env.adminPassword}`).toString("base64")}`;

describe("admin partner management", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mocks.passwordHash.mockResolvedValue("hashed-password");
  });

  it("lists only partners with their catalogue counts", async () => {
    mocks.userFindMany.mockResolvedValue([
      {
        id: "partner-1",
        name: "Partner One",
        email: "partner@example.com",
        createdAt: new Date("2026-07-17T00:00:00.000Z"),
        _count: { hotels: 2, tours: 1 },
      },
    ]);

    const response = await request(app)
      .get("/api/admin/partners")
      .set("Authorization", adminAuth);

    expect(response.status).toBe(200);
    expect(response.body).toHaveLength(1);
    expect(response.body[0]).toMatchObject({
      id: "partner-1",
      _count: { hotels: 2, tours: 1 },
    });
    expect(mocks.userFindMany).toHaveBeenCalledWith({
      where: { role: "PARTNER" },
      orderBy: { createdAt: "desc" },
      select: {
        id: true,
        name: true,
        email: true,
        createdAt: true,
        _count: { select: { hotels: true, tours: true } },
      },
    });
  });

  it("creates a Partner with the Partner role", async () => {
    mocks.userCreate.mockResolvedValue({
      id: "partner-1",
      name: "Partner One",
      email: "partner@example.com",
      role: "PARTNER",
    });

    const response = await request(app)
      .post("/api/admin/partners")
      .set("Authorization", adminAuth)
      .send({
        name: "Partner One",
        email: "partner@example.com",
        password: "secret-123",
      });

    expect(response.status).toBe(201);
    expect(mocks.passwordHash).toHaveBeenCalledWith("secret-123");
    expect(mocks.userCreate).toHaveBeenCalledWith({
      data: {
        name: "Partner One",
        email: "partner@example.com",
        password: "hashed-password",
        role: "PARTNER",
      },
    });
    expect(response.body).toEqual({
      id: "partner-1",
      name: "Partner One",
      email: "partner@example.com",
      role: "PARTNER",
    });
  });
});
