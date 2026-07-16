import crypto from "crypto";
import { HttpError } from "../utils/http-error.js";
import { getSafeImageExtension } from "../middleware/upload.js";

type StorageConfig = {
  baseUrl: string;
  serviceKey: string;
  bucket: string;
};

function storageConfigurationError(): HttpError {
  return new HttpError(503, "Image storage is not configured");
}

function readStorageConfig(): StorageConfig {
  const baseUrl = process.env.SUPABASE_URL?.trim().replace(/\/$/, "");
  const serviceKey = process.env.SUPABASE_SERVICE_ROLE_KEY?.trim();
  const bucket = process.env.SUPABASE_STORAGE_BUCKET?.trim();

  if (!baseUrl || !serviceKey || !bucket || !/^[a-z0-9][a-z0-9_-]{0,62}$/.test(bucket)) {
    throw storageConfigurationError();
  }

  try {
    const url = new URL(baseUrl);
    if (url.protocol !== "https:") throw new Error("Storage must use HTTPS");
  } catch {
    throw storageConfigurationError();
  }

  return { baseUrl, serviceKey, bucket };
}

function encodeObjectKey(objectKey: string): string {
  return objectKey.split("/").map(encodeURIComponent).join("/");
}

function parseManagedPublicObjectKey(
  value: string,
  baseUrl: string,
  bucket: string,
): string | null {
  if (!value.trim()) return null;

  try {
    const mediaUrl = new URL(value);
    const projectUrl = new URL(baseUrl);
    const pathPrefix = `/storage/v1/object/public/${encodeURIComponent(bucket)}/`;

    if (mediaUrl.origin !== projectUrl.origin || !mediaUrl.pathname.startsWith(pathPrefix)) {
      return null;
    }

    const objectKey = decodeURIComponent(mediaUrl.pathname.slice(pathPrefix.length));
    return objectKey ? objectKey : null;
  } catch {
    return null;
  }
}

export async function deleteManagedPublicImages(values: readonly string[]): Promise<void> {
  try {
    const { baseUrl, serviceKey, bucket } = readStorageConfig();
    const prefixes = [
      ...new Set(
        values.flatMap((value) => {
          const objectKey = parseManagedPublicObjectKey(value, baseUrl, bucket);
          return objectKey ? [objectKey] : [];
        }),
      ),
    ];

    if (!prefixes.length) return;

    const response = await fetch(
      `${baseUrl}/storage/v1/object/${encodeURIComponent(bucket)}`,
      {
        method: "DELETE",
        headers: {
          apikey: serviceKey,
          authorization: `Bearer ${serviceKey}`,
          "content-type": "application/json",
        },
        body: JSON.stringify({ prefixes }),
      },
    );

    if (!response.ok) {
      console.warn("Unable to delete replaced catalogue images", { count: prefixes.length });
    }
  } catch {
    console.warn("Unable to delete replaced catalogue images");
  }
}

export async function uploadPublicImage(file: Express.Multer.File): Promise<string> {
  const extension = getSafeImageExtension(file);
  if (!extension) throw new HttpError(400, "File type not allowed");

  const { baseUrl, serviceKey, bucket } = readStorageConfig();
  const objectKey = `catalog/${crypto.randomUUID()}${extension}`;
  const encodedBucket = encodeURIComponent(bucket);
  const encodedObjectKey = encodeObjectKey(objectKey);
  const body = new Uint8Array(file.buffer.byteLength);
  body.set(file.buffer);

  let response: Response;
  try {
    response = await fetch(`${baseUrl}/storage/v1/object/${encodedBucket}/${encodedObjectKey}`, {
      method: "POST",
      headers: {
        apikey: serviceKey,
        authorization: `Bearer ${serviceKey}`,
        "content-type": file.mimetype,
        "x-upsert": "false",
      },
      body,
    });
  } catch {
    throw new HttpError(502, "Image upload failed");
  }

  if (!response.ok) throw new HttpError(502, "Image upload failed");

  return `${baseUrl}/storage/v1/object/public/${encodedBucket}/${encodedObjectKey}`;
}
