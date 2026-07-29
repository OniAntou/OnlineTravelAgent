import jwt from "jsonwebtoken";
import request from "supertest";
import { beforeEach, describe, expect, it, vi } from "vitest";

const mocks = vi.hoisted(() => ({
  hotelFindFirst: vi.fn(),
  tourFindFirst: vi.fn(),
  tourCreate: vi.fn(),
  tourUpdate: vi.fn(),
  tourDelete: vi.fn(),
  roomFindFirst: vi.fn(),
  roomUpdateMany: vi.fn(),
  roomDeleteMany: vi.fn(),
  reviewDeleteMany: vi.fn(),
  transaction: vi.fn(),
}));

const media = vi.hoisted(() => ({
  deleteManagedPublicImages: vi.fn(),
}));

vi.mock("../../../src/infrastructure/database/prisma.js", () => ({
  default: {
    hotel: { findFirst: mocks.hotelFindFirst },
    tourPackage: {
      findFirst: mocks.tourFindFirst,
      create: mocks.tourCreate,
      update: mocks.tourUpdate,
      delete: mocks.tourDelete,
    },
    room: {
      findFirst: mocks.roomFindFirst,
      updateMany: mocks.roomUpdateMany,
      deleteMany: mocks.roomDeleteMany,
    },
    review: { deleteMany: mocks.reviewDeleteMany },
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
const oldImage = "https://project.supabase.co/storage/v1/object/public/travel-media/old.png";
const newImage = "https://project.supabase.co/storage/v1/object/public/travel-media/new.png";

describe("partner image lifecycle", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mocks.hotelFindFirst.mockResolvedValue({ id: "hotel-1" });
    mocks.tourFindFirst.mockResolvedValue({ id: "tour-1", imagePath: oldImage });
    mocks.tourCreate.mockImplementation(({ data }) => Promise.resolve({ id: "tour-1", ...data }));
    mocks.tourUpdate.mockImplementation(({ data }) => Promise.resolve({ id: "tour-1", ...data }));
    mocks.tourDelete.mockResolvedValue({ id: "tour-1" });
    mocks.roomFindFirst.mockResolvedValue({ imagePath: oldImage });
    mocks.roomUpdateMany.mockResolvedValue({ count: 1 });
    mocks.roomDeleteMany.mockResolvedValue({ count: 1 });
    mocks.reviewDeleteMany.mockResolvedValue({ count: 1 });
    mocks.transaction.mockImplementation(async (callback) =>
      callback({
        review: { deleteMany: mocks.reviewDeleteMany },
        tourPackage: { delete: mocks.tourDelete },
      }),
    );
    media.deleteManagedPublicImages.mockResolvedValue(undefined);
  });

  it("persists the uploaded image when a partner creates a tour", async () => {
    const response = await request(app)
      .post("/api/partner/tours")
      .set("Authorization", `Bearer ${partnerToken}`)
      .send({ name: "Tour with upload", imagePath: newImage });

    expect(response.status).toBe(201);
    expect(mocks.tourCreate).toHaveBeenCalledWith(expect.objectContaining({
      data: expect.objectContaining({ imagePath: newImage }),
    }));
  });

  it("persists every tour field that the partner form submits", async () => {
    const response = await request(app)
      .post("/api/partner/tours")
      .set("Authorization", `Bearer ${partnerToken}`)
      .send({
        name: "Complete tour",
        departureDate: "2026-09-01",
        originalPrice: 1200,
        isPopular: true,
        includesGuide: false,
        guideFee: 55,
      });

    expect(response.status).toBe(201);
    expect(mocks.tourCreate).toHaveBeenCalledWith(expect.objectContaining({
      data: expect.objectContaining({
        departureDate: "2026-09-01",
        originalPrice: 1200,
        isPopular: true,
        includesGuide: false,
        guideFee: 55,
      }),
    }));
  });

  it("deletes the replaced tour image only after its database update", async () => {
    const response = await request(app)
      .put("/api/partner/tours/tour-1")
      .set("Authorization", `Bearer ${partnerToken}`)
      .send({ name: "Updated tour", imagePath: newImage });

    expect(response.status).toBe(200);
    expect(mocks.tourUpdate).toHaveBeenCalledBefore(media.deleteManagedPublicImages as any);
    expect(media.deleteManagedPublicImages).toHaveBeenCalledWith([oldImage]);
  });

  it("keeps partner-editable tour fields when the tour is updated", async () => {
    const response = await request(app)
      .put("/api/partner/tours/tour-1")
      .set("Authorization", `Bearer ${partnerToken}`)
      .send({ name: "Updated tour", isPopular: true, includesGuide: false, guideFee: 35 });

    expect(response.status).toBe(200);
    expect(mocks.tourUpdate).toHaveBeenCalledWith(expect.objectContaining({
      data: expect.objectContaining({ isPopular: true, includesGuide: false, guideFee: 35 }),
    }));
  });

  it("deletes a removed room image after the room deletion", async () => {
    const response = await request(app)
      .delete("/api/partner/hotels/hotel-1/rooms/room-1")
      .set("Authorization", `Bearer ${partnerToken}`);

    expect(response.status).toBe(200);
    expect(mocks.roomDeleteMany).toHaveBeenCalledBefore(media.deleteManagedPublicImages as any);
    expect(media.deleteManagedPublicImages).toHaveBeenCalledWith([oldImage]);
  });
});
