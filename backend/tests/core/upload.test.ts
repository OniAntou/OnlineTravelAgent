import { beforeEach, describe, expect, it, vi } from "vitest";
import jwt from "jsonwebtoken";
import request from "supertest";

const mocks = vi.hoisted(() => {
  process.env.ADMIN_PASSWORD = "test-admin_password";
  process.env.JWT_SECRET = "test-jwt-secret";
  return { uploadPublicImage: vi.fn() };
});

vi.mock("../../src/core/storage/supabase-storage.js", () => ({
  uploadPublicImage: mocks.uploadPublicImage,
}));

import { app } from "../../src/app.js";

const adminAuth = `Basic ${Buffer.from("admin:test-admin_password").toString("base64")}`;
const partnerAuth = `Bearer ${jwt.sign({ userId: "partner-1", role: "PARTNER" }, "test-jwt-secret")}`;
const publicImageUrl = "https://project.supabase.co/storage/v1/object/public/travel-media/catalog/cover.png";

describe("upload middleware", () => {
  beforeEach(() => {
    mocks.uploadPublicImage.mockReset();
    mocks.uploadPublicImage.mockResolvedValue(publicImageUrl);
  });

  it("returns 400 when no file is attached", async () => {
    const res = await request(app)
      .post("/api/admin/upload")
      .set("Authorization", adminAuth);

    expect(res.status).toBe(400);
    expect(res.body.error).toBe("No file uploaded");
  });

  it("rejects unsupported file types as a client error", async () => {
    const res = await request(app)
      .post("/api/admin/upload")
      .set("Authorization", adminAuth)
      .attach("file", Buffer.from("not executable"), {
        filename: "malware.exe",
        contentType: "application/x-msdownload",
      });

    expect(res.status).toBe(400);
    expect(res.body.message).toContain("File type not allowed");
  });

  it("uploads an admin image through shared Storage", async () => {
    const res = await request(app)
      .post("/api/admin/upload")
      .set("Authorization", adminAuth)
      .attach("file", Buffer.from("png"), {
        filename: "cover.png",
        contentType: "image/png",
      });

    expect(res.status).toBe(200);
    expect(res.body).toEqual({ url: publicImageUrl });
    expect(mocks.uploadPublicImage).toHaveBeenCalledOnce();
  });

  it("uploads a partner image through shared Storage", async () => {
    const res = await request(app)
      .post("/api/partner/upload")
      .set("Authorization", partnerAuth)
      .attach("file", Buffer.from("png"), {
        filename: "cover.png",
        contentType: "image/png",
      });

    expect(res.status).toBe(200);
    expect(res.body).toEqual({ url: publicImageUrl });
    expect(mocks.uploadPublicImage).toHaveBeenCalledOnce();
  });
});
