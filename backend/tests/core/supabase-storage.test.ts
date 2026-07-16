import { afterEach, describe, expect, it, vi } from "vitest";
import { HttpError } from "../../src/core/utils/http-error.js";
import { uploadPublicImage } from "../../src/core/storage/supabase-storage.js";

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
});
