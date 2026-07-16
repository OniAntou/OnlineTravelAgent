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
