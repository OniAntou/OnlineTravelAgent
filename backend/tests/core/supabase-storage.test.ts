import { afterEach, describe, expect, it, vi } from "vitest";
import { HttpError } from "../../src/core/utils/http-error.js";

const prismaMock = vi.hoisted(() => ({
  destination: { findMany: vi.fn() },
  hotel: { findMany: vi.fn() },
  room: { findMany: vi.fn() },
  tourPackage: { findMany: vi.fn() },
  flight: { findMany: vi.fn() },
}));

vi.mock("../../src/infrastructure/database/prisma.js", () => ({
  default: prismaMock,
}));

import {
  cleanupAbandonedPendingImages,
  deleteManagedPublicImages,
  uploadPublicImage,
} from "../../src/core/storage/supabase-storage.js";

const pngFile = {
  buffer: Buffer.from("png"),
  mimetype: "image/png",
  originalname: "cover.png",
} as Express.Multer.File;

describe("Supabase image storage", () => {
  afterEach(() => {
    vi.restoreAllMocks();
    vi.unstubAllEnvs();
    for (const model of Object.values(prismaMock)) {
      model.findMany.mockReset();
    }
  });

  it("uploads an image with server credentials and returns its public URL", async () => {
    vi.stubEnv("SUPABASE_URL", "https://project.supabase.co");
    vi.stubEnv("SUPABASE_SERVICE_ROLE_KEY", "service-secret");
    vi.stubEnv("SUPABASE_STORAGE_BUCKET", "travel-media");
    const fetchMock = vi.spyOn(globalThis, "fetch").mockResolvedValue(new Response("{}", { status: 200 }));

    const url = await uploadPublicImage(pngFile);

    expect(url).toMatch(
      /^https:\/\/project\.supabase\.co\/storage\/v1\/object\/public\/travel-media\/pending\/.+\.png$/,
    );
    expect(fetchMock).toHaveBeenCalledWith(
      expect.stringContaining("/storage/v1/object/travel-media/pending/"),
      expect.objectContaining({
        method: "POST",
        headers: expect.objectContaining({
          apikey: "service-secret",
          "content-type": "image/png",
          "x-upsert": "false",
        }),
      }),
    );
  });

  it("fails safely when Storage is not configured", async () => {
    vi.stubEnv("SUPABASE_URL", "");
    vi.stubEnv("SUPABASE_SERVICE_ROLE_KEY", "");
    vi.stubEnv("SUPABASE_STORAGE_BUCKET", "");

    await expect(uploadPublicImage(pngFile)).rejects.toMatchObject<HttpError>({
      statusCode: 503,
      message: "Image storage is not configured",
    });
  });

  it("maps an upstream Storage error to a safe response", async () => {
    vi.stubEnv("SUPABASE_URL", "https://project.supabase.co");
    vi.stubEnv("SUPABASE_SERVICE_ROLE_KEY", "service-secret");
    vi.stubEnv("SUPABASE_STORAGE_BUCKET", "travel-media");
    vi.spyOn(globalThis, "fetch").mockResolvedValue(new Response("unexpected details", { status: 500 }));

    await expect(uploadPublicImage(pngFile)).rejects.toMatchObject<HttpError>({
      statusCode: 502,
      message: "Image upload failed",
    });
  });

  it("deletes only this project's managed public images", async () => {
    vi.stubEnv("SUPABASE_URL", "https://project.supabase.co");
    vi.stubEnv("SUPABASE_SERVICE_ROLE_KEY", "service-secret");
    vi.stubEnv("SUPABASE_STORAGE_BUCKET", "travel-media");
    const fetchMock = vi.spyOn(globalThis, "fetch").mockResolvedValue(new Response("{}", { status: 200 }));

    await deleteManagedPublicImages([
      "https://project.supabase.co/storage/v1/object/public/travel-media/catalog/old.png",
      "https://project.supabase.co/storage/v1/object/public/travel-media/catalog/old.png",
      "assets/images/legacy.png",
      "/uploads/legacy.png",
      "https://other-project.supabase.co/storage/v1/object/public/travel-media/catalog/other.png",
      "https://project.supabase.co/storage/v1/object/public/other-bucket/catalog/other.png",
    ]);

    expect(fetchMock).toHaveBeenCalledOnce();
    expect(fetchMock).toHaveBeenCalledWith(
      "https://project.supabase.co/storage/v1/object/travel-media",
      expect.objectContaining({
        method: "DELETE",
        body: JSON.stringify({ prefixes: ["catalog/old.png"] }),
      }),
    );
  });

  it("does not let Storage cleanup failures fail a CRUD operation", async () => {
    vi.stubEnv("SUPABASE_URL", "https://project.supabase.co");
    vi.stubEnv("SUPABASE_SERVICE_ROLE_KEY", "service-secret");
    vi.stubEnv("SUPABASE_STORAGE_BUCKET", "travel-media");
    const warn = vi.spyOn(console, "warn").mockImplementation(() => undefined);
    vi.spyOn(globalThis, "fetch").mockResolvedValue(new Response("failure", { status: 500 }));

    await expect(
      deleteManagedPublicImages([
        "https://project.supabase.co/storage/v1/object/public/travel-media/catalog/old.png",
      ]),
    ).resolves.toBeUndefined();
    expect(warn).toHaveBeenCalledWith(
      "Unable to delete replaced catalogue images",
      { count: 1 },
    );
  });

  it("ignores private, malformed, and empty image references", async () => {
    vi.stubEnv("SUPABASE_URL", "https://project.supabase.co");
    vi.stubEnv("SUPABASE_SERVICE_ROLE_KEY", "service-secret");
    vi.stubEnv("SUPABASE_STORAGE_BUCKET", "travel-media");
    const fetchMock = vi.spyOn(globalThis, "fetch");

    await deleteManagedPublicImages([
      "",
      "not a URL",
      "https://project.supabase.co/storage/v1/object/sign/travel-media/catalog/private.png",
      "https://project.supabase.co/storage/v1/object/public/travel-media/",
    ]);

    expect(fetchMock).not.toHaveBeenCalled();
  });

  it("reclaims only expired pending files that no catalogue record references", async () => {
    vi.stubEnv("SUPABASE_URL", "https://project.supabase.co");
    vi.stubEnv("SUPABASE_SERVICE_ROLE_KEY", "service-secret");
    vi.stubEnv("SUPABASE_STORAGE_BUCKET", "travel-media");
    prismaMock.destination.findMany.mockResolvedValue([
      { imagePath: "https://project.supabase.co/storage/v1/object/public/travel-media/pending/linked.png" },
    ]);
    prismaMock.hotel.findMany.mockResolvedValue([]);
    prismaMock.room.findMany.mockResolvedValue([]);
    prismaMock.tourPackage.findMany.mockResolvedValue([]);
    prismaMock.flight.findMany.mockResolvedValue([]);
    const fetchMock = vi.spyOn(globalThis, "fetch")
      .mockResolvedValueOnce(new Response(JSON.stringify([
        { name: "linked.png", created_at: "2026-01-01T00:00:00.000Z" },
        { name: "abandoned.png", created_at: "2026-01-01T00:00:00.000Z" },
        { name: "fresh.png", created_at: "2026-01-01T01:30:00.000Z" },
      ]), { status: 200 }))
      .mockResolvedValueOnce(new Response("{}", { status: 200 }));

    await expect(cleanupAbandonedPendingImages({
      now: new Date("2026-01-01T02:00:00.000Z"),
      graceMinutes: 60,
    })).resolves.toBe(1);

    expect(fetchMock).toHaveBeenNthCalledWith(
      2,
      "https://project.supabase.co/storage/v1/object/travel-media",
      expect.objectContaining({
        method: "DELETE",
        body: JSON.stringify({ prefixes: ["pending/abandoned.png"] }),
      }),
    );
  });
});
