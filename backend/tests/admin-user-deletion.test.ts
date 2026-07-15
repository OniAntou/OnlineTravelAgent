import request from "supertest";
import { beforeEach, describe, expect, it, vi } from "vitest";

const mocks = vi.hoisted(() => ({
  reviewDeleteMany: vi.fn(),
  userDelete: vi.fn(),
  transaction: vi.fn(),
}));

vi.mock("../src/infrastructure/database/prisma.js", () => ({
  default: {
    review: { deleteMany: mocks.reviewDeleteMany },
    user: { delete: mocks.userDelete },
    $transaction: mocks.transaction,
  },
}));

import { app } from "../src/app.js";
import { env } from "../src/core/config/env.js";

const adminAuth = `Basic ${Buffer.from(`admin:${env.adminPassword}`).toString("base64")}`;

describe("admin user deletion", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mocks.reviewDeleteMany.mockResolvedValue({ count: 3 });
    mocks.userDelete.mockResolvedValue({ id: "user-1" });
    mocks.transaction.mockImplementation(async (callback) =>
      callback({
        review: { deleteMany: mocks.reviewDeleteMany },
        user: { delete: mocks.userDelete },
      }),
    );
  });

  it("removes a user's reviews before deleting that user", async () => {
    const res = await request(app)
      .delete("/api/admin/users/user-1")
      .set("Authorization", adminAuth);

    expect(res.status).toBe(200);
    expect(mocks.reviewDeleteMany).toHaveBeenCalledWith({
      where: { userId: "user-1" },
    });
    expect(mocks.userDelete).toHaveBeenCalledWith({
      where: { id: "user-1" },
    });
    expect(mocks.transaction).toHaveBeenCalledOnce();
  });
});
