import prisma from "../../infrastructure/database/prisma.js";

export class PersistentDataUnavailableError extends Error {
  constructor() {
    super("Persistent data storage is unavailable");
    this.name = "PersistentDataUnavailableError";
  }
}

const PERSISTENT_DATA_AVAILABILITY_TTL_MS = 2_000;

type AvailabilityCache = {
  available: boolean;
  checkedAt: number;
};

let availabilityCache: AvailabilityCache | undefined;
let availabilityProbe: Promise<boolean> | undefined;

export function isMemoryFallbackEnabled(): boolean {
  return process.env.NODE_ENV !== "production";
}

export function assertMemoryFallbackEnabled(): void {
  if (!isMemoryFallbackEnabled()) {
    throw new PersistentDataUnavailableError();
  }
}

async function probePersistentData(): Promise<boolean> {
  try {
    await prisma.$queryRaw`SELECT 1`;
    return true;
  } catch {
    return false;
  }
}

export async function isPersistentDataAvailable(
  options: { force?: boolean } = {},
): Promise<boolean> {
  const now = Date.now();
  if (
    !options.force &&
    availabilityCache &&
    now - availabilityCache.checkedAt < PERSISTENT_DATA_AVAILABILITY_TTL_MS
  ) {
    return availabilityCache.available;
  }

  if (!options.force && availabilityProbe) {
    return availabilityProbe;
  }

  const probe = probePersistentData();
  if (!options.force) availabilityProbe = probe;

  try {
    const available = await probe;
    availabilityCache = { available, checkedAt: Date.now() };
    return available;
  } finally {
    if (availabilityProbe === probe) availabilityProbe = undefined;
  }
}

export async function shouldUseMemoryFallback(): Promise<boolean> {
  if (await isPersistentDataAvailable()) return false;
  assertMemoryFallbackEnabled();
  return true;
}

export function resetPersistentDataAvailabilityCache(): void {
  availabilityCache = undefined;
  availabilityProbe = undefined;
}
