import crypto from "crypto";
import prisma from "../../infrastructure/database/prisma.js";
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

function publicObjectUrl(config: StorageConfig, objectKey: string): string {
  return `${config.baseUrl}/storage/v1/object/public/${encodeURIComponent(config.bucket)}/${encodeObjectKey(objectKey)}`;
}

async function getReferencedObjectKeys(config: StorageConfig): Promise<Set<string>> {
  const [destinations, hotels, rooms, tours, flights] = await Promise.all([
    prisma.destination.findMany({ select: { imagePath: true } }),
    prisma.hotel.findMany({ select: { imagePath: true } }),
    prisma.room.findMany({ select: { imagePath: true } }),
    prisma.tourPackage.findMany({ select: { imagePath: true } }),
    prisma.flight.findMany({ select: { airlineLogo: true } }),
  ]);

  const values = [
    ...destinations.map((item) => item.imagePath),
    ...hotels.map((item) => item.imagePath),
    ...rooms.map((item) => item.imagePath),
    ...tours.map((item) => item.imagePath),
    ...flights.map((item) => item.airlineLogo),
  ];
  return new Set(
    values.flatMap((value) => {
      const objectKey = parseManagedPublicObjectKey(value, config.baseUrl, config.bucket);
      return objectKey ? [objectKey] : [];
    }),
  );
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
  // The form may be abandoned after this request. Keep new objects in a
  // separate prefix so the bounded cleanup job can reclaim unreferenced files.
  const objectKey = `pending/${crypto.randomUUID()}${extension}`;
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

  return publicObjectUrl({ baseUrl, serviceKey, bucket }, objectKey);
}

type PendingStorageObject = {
  name?: unknown;
  created_at?: unknown;
};

function readPositiveMinutes(name: string, fallback: number): number {
  const value = Number.parseInt(process.env[name] ?? "", 10);
  return Number.isInteger(value) && value > 0 ? value : fallback;
}

/**
 * Deletes only expired uploaded files which are not referenced by any catalogue
 * record. A storage or database failure is deliberately a no-op so cleanup can
 * never make a successful CRUD request fail.
 */
export async function cleanupAbandonedPendingImages(
  options: { now?: Date; graceMinutes?: number } = {},
): Promise<number> {
  try {
    const config = readStorageConfig();
    const response = await fetch(
      `${config.baseUrl}/storage/v1/object/list/${encodeURIComponent(config.bucket)}`,
      {
        method: "POST",
        headers: {
          apikey: config.serviceKey,
          authorization: `Bearer ${config.serviceKey}`,
          "content-type": "application/json",
        },
        body: JSON.stringify({ prefix: "pending/", limit: 1000, offset: 0 }),
      },
    );
    if (!response.ok) return 0;

    const objects = await response.json() as PendingStorageObject[];
    const referenced = await getReferencedObjectKeys(config);
    const cutoff = (options.now ?? new Date()).getTime()
      - (options.graceMinutes ?? readPositiveMinutes("PENDING_IMAGE_GRACE_MINUTES", 60)) * 60_000;
    const stale = objects.flatMap((object) => {
      if (typeof object.name !== "string" || typeof object.created_at !== "string") return [];
      const createdAt = Date.parse(object.created_at);
      if (!Number.isFinite(createdAt) || createdAt > cutoff) return [];
      const objectKey = object.name.startsWith("pending/") ? object.name : `pending/${object.name}`;
      return referenced.has(objectKey) ? [] : [objectKey];
    });
    if (!stale.length) return 0;

    await deleteManagedPublicImages(stale.map((objectKey) => publicObjectUrl(config, objectKey)));
    return stale.length;
  } catch {
    return 0;
  }
}

export function startPendingImageCleanup(): () => void {
  const intervalMinutes = readPositiveMinutes("PENDING_IMAGE_CLEANUP_INTERVAL_MINUTES", 60);
  const timer = setInterval(() => {
    void cleanupAbandonedPendingImages();
  }, intervalMinutes * 60_000);
  timer.unref();
  return () => clearInterval(timer);
}
