import request from "supertest";
import { beforeEach, describe, expect, it, vi } from "vitest";

const mocks = vi.hoisted(() => ({
  reviewDeleteMany: vi.fn(),
  destinationFindUnique: vi.fn(),
  destinationUpdate: vi.fn(),
  destinationDelete: vi.fn(),
  flightFindUnique: vi.fn(),
  flightDelete: vi.fn(),
  tourPackageFindUnique: vi.fn(),
  tourPackageDelete: vi.fn(),
  categoryFindUnique: vi.fn(),
  categoryDelete: vi.fn(),
  transaction: vi.fn(),
}));

const media = vi.hoisted(() => ({
  deleteManagedPublicImages: vi.fn(),
}));

vi.mock("../../../src/infrastructure/database/prisma.js", () => ({
  default: {
    review: { deleteMany: mocks.reviewDeleteMany },
    destination: {
      findUnique: mocks.destinationFindUnique,
      update: mocks.destinationUpdate,
      delete: mocks.destinationDelete,
    },
    flight: { findUnique: mocks.flightFindUnique, delete: mocks.flightDelete },
    tourPackage: { findUnique: mocks.tourPackageFindUnique, delete: mocks.tourPackageDelete },
    category: {
      findUnique: mocks.categoryFindUnique,
      delete: mocks.categoryDelete,
    },
    $transaction: mocks.transaction,
  },
}));

vi.mock("../../../src/core/storage/supabase-storage.js", () => media);

import { app } from "../../../src/app.js";
import { env } from "../../../src/core/config/env.js";

const adminAuth = `Basic ${Buffer.from(`admin:${env.adminPassword}`).toString("base64")}`;

describe("admin catalogue deletion", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mocks.reviewDeleteMany.mockResolvedValue({ count: 1 });
    mocks.destinationFindUnique.mockResolvedValue({ imagePath: "assets/images/legacy.png" });
    mocks.destinationUpdate.mockResolvedValue({ id: "destination-1" });
    mocks.destinationDelete.mockResolvedValue({ id: "destination-1" });
    mocks.flightFindUnique.mockResolvedValue({ airlineLogo: "assets/images/legacy.png" });
    mocks.flightDelete.mockResolvedValue({ id: "flight-1" });
    mocks.tourPackageFindUnique.mockResolvedValue({ imagePath: "assets/images/legacy.png" });
    mocks.tourPackageDelete.mockResolvedValue({ id: "tour-1" });
    mocks.categoryDelete.mockResolvedValue({ id: "category-empty" });
    media.deleteManagedPublicImages.mockResolvedValue(undefined);
    mocks.transaction.mockImplementation(async (callback) =>
      callback({
        review: { deleteMany: mocks.reviewDeleteMany },
        destination: { delete: mocks.destinationDelete },
        flight: { delete: mocks.flightDelete },
        tourPackage: { delete: mocks.tourPackageDelete },
      }),
    );
  });

  it("removes destination reviews in the same transaction", async () => {
    const res = await request(app)
      .delete("/api/admin/destinations/destination-1")
      .set("Authorization", adminAuth);

    expect(res.status).toBe(200);
    expect(mocks.reviewDeleteMany).toHaveBeenCalledWith({
      where: { targetType: "destination", targetId: "destination-1" },
    });
    expect(mocks.destinationDelete).toHaveBeenCalledWith({
      where: { id: "destination-1" },
    });
    expect(mocks.transaction).toHaveBeenCalledOnce();
  });

  it("reclaims a replaced destination image after the update", async () => {
    const oldImage = "https://project.supabase.co/storage/v1/object/public/travel-media/catalog/old.png";
    const newImage = "https://project.supabase.co/storage/v1/object/public/travel-media/catalog/new.png";
    mocks.destinationFindUnique.mockResolvedValue({ imagePath: oldImage });

    const res = await request(app)
      .put("/api/admin/destinations/destination-1")
      .set("Authorization", adminAuth)
      .send({ name: "Updated destination", location: "Da Nang", imagePath: newImage });

    expect(res.status).toBe(200);
    expect(mocks.destinationUpdate).toHaveBeenCalledBefore(media.deleteManagedPublicImages as any);
    expect(media.deleteManagedPublicImages).toHaveBeenCalledWith([oldImage]);
  });

  it("removes flight reviews in the same transaction", async () => {
    const res = await request(app)
      .delete("/api/admin/flights/flight-1")
      .set("Authorization", adminAuth);

    expect(res.status).toBe(200);
    expect(mocks.reviewDeleteMany).toHaveBeenCalledWith({
      where: { targetType: "flight", targetId: "flight-1" },
    });
    expect(mocks.flightDelete).toHaveBeenCalledWith({
      where: { id: "flight-1" },
    });
    expect(mocks.transaction).toHaveBeenCalledOnce();
  });

  it("removes tour reviews in the same transaction", async () => {
    const res = await request(app)
      .delete("/api/admin/tours/tour-1")
      .set("Authorization", adminAuth);

    expect(res.status).toBe(200);
    expect(mocks.reviewDeleteMany).toHaveBeenCalledWith({
      where: { targetType: "tour", targetId: "tour-1" },
    });
    expect(mocks.tourPackageDelete).toHaveBeenCalledWith({
      where: { id: "tour-1" },
    });
    expect(mocks.transaction).toHaveBeenCalledOnce();
  });

  it("rejects deletion of a category that still has destinations", async () => {
    mocks.categoryFindUnique.mockResolvedValue({
      id: "category-used",
      _count: { destinations: 1 },
    });

    const res = await request(app)
      .delete("/api/admin/categories/category-used")
      .set("Authorization", adminAuth);

    expect(res.status).toBe(409);
    expect(res.body).toEqual({ message: "Category is still assigned to destinations" });
    expect(mocks.categoryDelete).not.toHaveBeenCalled();
  });

  it("deletes an empty category", async () => {
    mocks.categoryFindUnique.mockResolvedValue({
      id: "category-empty",
      _count: { destinations: 0 },
    });

    const res = await request(app)
      .delete("/api/admin/categories/category-empty")
      .set("Authorization", adminAuth);

    expect(res.status).toBe(200);
    expect(mocks.categoryDelete).toHaveBeenCalledWith({
      where: { id: "category-empty" },
    });
  });
});
