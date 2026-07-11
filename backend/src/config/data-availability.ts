export class PersistentDataUnavailableError extends Error {
  constructor() {
    super("Persistent data storage is unavailable");
    this.name = "PersistentDataUnavailableError";
  }
}

export function isMemoryFallbackEnabled(): boolean {
  return process.env.NODE_ENV !== "production";
}

export function assertMemoryFallbackEnabled(): void {
  if (!isMemoryFallbackEnabled()) {
    throw new PersistentDataUnavailableError();
  }
}
