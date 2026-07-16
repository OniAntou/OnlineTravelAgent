import request from "supertest";
import { beforeEach, describe, expect, it, vi } from "vitest";

const mocks = vi.hoisted(() => ({
  reviewDeleteMany: vi.fn(),
  roomDeleteMany: vi.fn(),
  hotelFindUnique: vi.fn(),
  hotelDelete: vi.fn(),
  transaction: vi.fn(),
}));

const media = vi.hoisted(() => ({
  deleteManagedPublicImages: vi.fn(),
}));

vi.mock("../../../src/infrastructure/database/prisma.js", () => ({
  default: {
    review: { deleteMany: mocks.reviewDeleteMany },
    room: { deleteMany: mocks.roomDeleteMany },
    hotel: { findUnique: mocks.hotelFindUnique, delete: mocks.hotelDelete },
    $transaction: mocks.transaction,
  },
}));

vi.mock("../../../src/core/storage/supabase-storage.js", () => media);

import { app } from "../../../src/app.js";
import { env } from "../../../src/core/config/env.js";

const adminAuth = `Basic ${Buffer.from(`admin:${env.adminPassword}`).toString("base64")}`;

describe("admin hotel deletion", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mocks.reviewDeleteMany.mockResolvedValue({ count: 1 });
    mocks.roomDeleteMany.mockResolvedValue({ count: 2 });
    mocks.hotelFindUnique.mockResolvedValue({
      imagePath: "assets/images/legacy.png",
      rooms: [{ imagePath: "assets/images/legacy-room.png" }],
    });
    mocks.hotelDelete.mockResolvedValue({ id: "hotel-1" });
    media.deleteManagedPublicImages.mockResolvedValue(undefined);
    mocks.transaction.mockImplementation((run) =>
      run({
        review: { deleteMany: mocks.reviewDeleteMany },
        room: { deleteMany: mocks.roomDeleteMany },
        hotel: { delete: mocks.hotelDelete },
      }),
    );
  });

  it("deletes reviews, rooms, and hotel atomically", async () => {
    const response = await request(app)
      .delete("/api/admin/hotels/hotel-1")
      .set("Authorization", adminAuth);

    expect(response.status).toBe(200);
    expect(mocks.transaction).toHaveBeenCalledOnce();
    expect(mocks.reviewDeleteMany).toHaveBeenCalledWith({
      where: { targetType: "hotel", targetId: "hotel-1" },
    });
    expect(mocks.roomDeleteMany).toHaveBeenCalledWith({
      where: { hotelId: "hotel-1" },
    });
    expect(mocks.hotelDelete).toHaveBeenCalledWith({ where: { id: "hotel-1" } });
  });
});
