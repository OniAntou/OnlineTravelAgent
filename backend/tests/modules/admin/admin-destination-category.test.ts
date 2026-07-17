import request from "supertest";
import { beforeEach, describe, expect, it, vi } from "vitest";

const mocks = vi.hoisted(() => ({
  categoryFindUnique: vi.fn(),
  destinationCreate: vi.fn(),
}));

vi.mock("../../../src/infrastructure/database/prisma.js", () => ({
  default: {
    category: { findUnique: mocks.categoryFindUnique },
    destination: { create: mocks.destinationCreate },
  },
}));

import { app } from "../../../src/app.js";
import { env } from "../../../src/core/config/env.js";

const adminAuth = `Basic ${Buffer.from(`admin:${env.adminPassword}`).toString("base64")}`;

describe("admin destination categories", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("rejects a destination category that does not exist", async () => {
    mocks.categoryFindUnique.mockResolvedValue(null);

    const response = await request(app)
      .post("/api/admin/destinations")
      .set("Authorization", adminAuth)
      .send({
        id: "destination-invalid-category",
        name: "Invalid category destination",
        location: "Da Nang",
        category: "Does not exist",
      });

    expect(response.status).toBe(400);
    expect(response.body).toEqual({ message: "Category not found" });
    expect(mocks.destinationCreate).not.toHaveBeenCalled();
  });
});
