import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";

const mocks = vi.hoisted(() => ({
  queryRaw: vi.fn(),
}));

vi.mock("../../src/infrastructure/database/prisma.js", () => ({
  default: { $queryRaw: mocks.queryRaw },
}));

import {
  isPersistentDataAvailable,
  resetPersistentDataAvailabilityCache,
  shouldUseMemoryFallback,
} from "../../src/core/config/data-availability.js";

describe("persistent data availability", () => {
  const originalNodeEnv = process.env.NODE_ENV;

  beforeEach(() => {
    vi.clearAllMocks();
    resetPersistentDataAvailabilityCache();
    process.env.NODE_ENV = "test";
  });

  afterEach(() => {
    process.env.NODE_ENV = originalNodeEnv;
  });

  it("shares one in-flight probe and reuses the short-lived result", async () => {
    mocks.queryRaw.mockResolvedValue([{ ok: 1 }]);

    await Promise.all([
      isPersistentDataAvailable(),
      isPersistentDataAvailable(),
    ]);
    await isPersistentDataAvailable();

    expect(mocks.queryRaw).toHaveBeenCalledTimes(1);
  });

  it("uses memory fallback only outside production", async () => {
    mocks.queryRaw.mockRejectedValue(new Error("database unavailable"));

    await expect(shouldUseMemoryFallback()).resolves.toBe(true);

    resetPersistentDataAvailabilityCache();
    process.env.NODE_ENV = "production";
    await expect(shouldUseMemoryFallback()).rejects.toMatchObject({
      name: "PersistentDataUnavailableError",
    });
  });

  it("forces a fresh health-style probe when requested", async () => {
    mocks.queryRaw.mockResolvedValue([{ ok: 1 }]);

    await isPersistentDataAvailable();
    await isPersistentDataAvailable({ force: true });

    expect(mocks.queryRaw).toHaveBeenCalledTimes(2);
  });
});
