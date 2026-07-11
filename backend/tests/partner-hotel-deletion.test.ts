import jwt from "jsonwebtoken";
import request from "supertest";
import { beforeEach, describe, expect, it, vi } from "vitest";

const mocks = vi.hoisted(() => ({
  hotelFindFirst: vi.fn(),
  hotelDelete: vi.fn(),
  roomDeleteMany: vi.fn(),
  transaction: vi.fn(),
}));

vi.mock("../src/config/prisma.js", () => ({
  default: {
    hotel: {
      findFirst: mocks.hotelFindFirst,
      delete: mocks.hotelDelete,
    },
    room: {
      deleteMany: mocks.roomDeleteMany,
    },
    $transaction: mocks.transaction,
  },
}));

import { app } from "../src/app.js";
import { env } from "../src/config/env.js";

const partnerToken = jwt.sign(
  { userId: "partner-1", role: "PARTNER" },
  env.jwtSecret,
);

describe("partner hotel deletion", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mocks.hotelFindFirst.mockResolvedValue({ id: "hotel-1" });
    mocks.roomDeleteMany.mockResolvedValue({ count: 2 });
    mocks.hotelDelete.mockResolvedValue({ id: "hotel-1" });
    mocks.transaction.mockImplementation(async (callback) =>
      callback({
        room: { deleteMany: mocks.roomDeleteMany },
        hotel: { delete: mocks.hotelDelete },
      }),
    );
  });

  it("removes a partner hotel's rooms before deleting the hotel", async () => {
    const res = await request(app)
      .delete("/api/partner/hotels/hotel-1")
      .set("Authorization", `Bearer ${partnerToken}`);

    expect(res.status).toBe(200);
    expect(mocks.roomDeleteMany).toHaveBeenCalledWith({
      where: { hotelId: "hotel-1" },
    });
    expect(mocks.hotelDelete).toHaveBeenCalledWith({
      where: { id: "hotel-1" },
    });
    expect(mocks.transaction).toHaveBeenCalledOnce();
  });
});
