import { afterEach, describe, expect, it, vi } from "vitest";
import { HttpError } from "../../src/core/utils/http-error.js";
import {
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
  });

  it("uploads an image with server credentials and returns its public URL", async () => {
    vi.stubEnv("SUPABASE_URL", "https://project.supabase.co");
    vi.stubEnv("SUPABASE_SERVICE_ROLE_KEY", "service-secret");
    vi.stubEnv("SUPABASE_STORAGE_BUCKET", "travel-media");
    const fetchMock = vi.spyOn(globalThis, "fetch").mockResolvedValue(new Response("{}", { status: 200 }));

    const url = await uploadPublicImage(pngFile);

    expect(url).toMatch(
      /^https:\/\/project\.supabase\.co\/storage\/v1\/object\/public\/travel-media\/catalog\/.+\.png$/,
    );
    expect(fetchMock).toHaveBeenCalledWith(
      expect.stringContaining("/storage/v1/object/travel-media/catalog/"),
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
});
