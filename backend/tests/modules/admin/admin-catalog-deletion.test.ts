import request from "supertest";
import { beforeEach, describe, expect, it, vi } from "vitest";

const mocks = vi.hoisted(() => ({
  reviewDeleteMany: vi.fn(),
  destinationDelete: vi.fn(),
  flightDelete: vi.fn(),
  tourPackageDelete: vi.fn(),
  categoryFindUnique: vi.fn(),
  categoryDelete: vi.fn(),
  transaction: vi.fn(),
}));

vi.mock("../../../src/infrastructure/database/prisma.js", () => ({
  default: {
    review: { deleteMany: mocks.reviewDeleteMany },
    destination: { delete: mocks.destinationDelete },
    flight: { delete: mocks.flightDelete },
    tourPackage: { delete: mocks.tourPackageDelete },
    category: {
      findUnique: mocks.categoryFindUnique,
      delete: mocks.categoryDelete,
    },
    $transaction: mocks.transaction,
  },
}));

import { app } from "../../../src/app.js";
import { env } from "../../../src/core/config/env.js";

const adminAuth = `Basic ${Buffer.from(`admin:${env.adminPassword}`).toString("base64")}`;

describe("admin catalogue deletion", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mocks.reviewDeleteMany.mockResolvedValue({ count: 1 });
    mocks.destinationDelete.mockResolvedValue({ id: "destination-1" });
    mocks.flightDelete.mockResolvedValue({ id: "flight-1" });
    mocks.tourPackageDelete.mockResolvedValue({ id: "tour-1" });
    mocks.categoryDelete.mockResolvedValue({ id: "category-empty" });
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
