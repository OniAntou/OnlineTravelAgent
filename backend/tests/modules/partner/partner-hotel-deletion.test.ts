import jwt from "jsonwebtoken";
import request from "supertest";
import { beforeEach, describe, expect, it, vi } from "vitest";

const mocks = vi.hoisted(() => ({
  hotelFindFirst: vi.fn(),
  hotelFindMany: vi.fn(),
  hotelDelete: vi.fn(),
  reviewDeleteMany: vi.fn(),
  roomFindMany: vi.fn(),
  roomDeleteMany: vi.fn(),
  transaction: vi.fn(),
}));

const media = vi.hoisted(() => ({
  deleteManagedPublicImages: vi.fn(),
}));

vi.mock("../../../src/infrastructure/database/prisma.js", () => ({
  default: {
    review: { deleteMany: mocks.reviewDeleteMany },
    hotel: {
      findFirst: mocks.hotelFindFirst,
      findMany: mocks.hotelFindMany,
      delete: mocks.hotelDelete,
    },
    room: {
      findMany: mocks.roomFindMany,
      deleteMany: mocks.roomDeleteMany,
    },
    $transaction: mocks.transaction,
  },
}));

vi.mock("../../../src/core/storage/supabase-storage.js", () => media);

import { app } from "../../../src/app.js";
import { env } from "../../../src/core/config/env.js";

const partnerToken = jwt.sign(
  { userId: "partner-1", role: "PARTNER" },
  env.jwtSecret,
);

describe("partner hotel deletion", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mocks.hotelFindFirst.mockResolvedValue({ id: "hotel-1", imagePath: "assets/images/legacy.png" });
    mocks.hotelFindMany.mockResolvedValue([{ id: "hotel-1", rooms: [] }]);
    mocks.reviewDeleteMany.mockResolvedValue({ count: 1 });
    mocks.roomFindMany.mockResolvedValue([{ imagePath: "assets/images/legacy-room.png" }]);
    mocks.roomDeleteMany.mockResolvedValue({ count: 2 });
    mocks.hotelDelete.mockResolvedValue({ id: "hotel-1" });
    media.deleteManagedPublicImages.mockResolvedValue(undefined);
    mocks.transaction.mockImplementation(async (callback) =>
      callback({
        review: { deleteMany: mocks.reviewDeleteMany },
        room: { deleteMany: mocks.roomDeleteMany },
        hotel: { delete: mocks.hotelDelete },
      }),
    );
  });

  it("removes a partner hotel's reviews and rooms before deleting the hotel", async () => {
    const res = await request(app)
      .delete("/api/partner/hotels/hotel-1")
      .set("Authorization", `Bearer ${partnerToken}`);

    expect(res.status).toBe(200);
    expect(mocks.reviewDeleteMany).toHaveBeenCalledWith({
      where: { targetType: "hotel", targetId: "hotel-1" },
    });
    expect(mocks.roomDeleteMany).toHaveBeenCalledWith({
      where: { hotelId: "hotel-1" },
    });
    expect(mocks.hotelDelete).toHaveBeenCalledWith({
      where: { id: "hotel-1" },
    });
    expect(mocks.transaction).toHaveBeenCalledOnce();
  });

  it("includes rooms in the partner hotel list", async () => {
    const res = await request(app)
      .get("/api/partner/hotels")
      .set("Authorization", `Bearer ${partnerToken}`);

    expect(res.status).toBe(200);
    expect(mocks.hotelFindMany).toHaveBeenCalledWith({
      where: { partnerId: "partner-1" },
      include: { rooms: true },
    });
  });
});
