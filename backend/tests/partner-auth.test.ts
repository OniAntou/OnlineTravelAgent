import jwt from "jsonwebtoken";
import request from "supertest";
import { beforeEach, describe, expect, it, vi } from "vitest";

const mocks = vi.hoisted(() => ({
  userUpdate: vi.fn(),
}));

vi.mock("../src/infrastructure/database/prisma.js", () => ({
  default: {
    user: {
      update: mocks.userUpdate,
    },
  },
}));

import { app } from "../src/app.js";

import { env } from "../src/core/config/env.js";

const userToken = jwt.sign({ userId: "user-1", role: "USER" }, env.jwtSecret);

describe("partner role elevation", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("does not let a normal user self-promote to partner", async () => {
    const res = await request(app)
      .post("/api/auth/become-partner")
      .set("Authorization", `Bearer ${userToken}`)
      .send({});

    expect(res.status).toBe(403);
    expect(mocks.userUpdate).not.toHaveBeenCalled();
  });
});
