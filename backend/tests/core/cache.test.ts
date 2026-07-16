import { afterEach, describe, expect, it } from "vitest";
import {
  appCache,
  BOOTSTRAP_BASE_KEY,
  invalidateBootstrapBaseCache,
} from "../../src/core/config/cache.js";

describe("bootstrap base cache invalidation", () => {
  afterEach(() => {
    appCache.flushAll();
  });

  it("removes only the shared bootstrap base entry", () => {
    appCache.set(BOOTSTRAP_BASE_KEY, { destinations: [] });
    appCache.set("search:da-lat", { destinations: [] });

    invalidateBootstrapBaseCache();

    expect(appCache.get(BOOTSTRAP_BASE_KEY)).toBeUndefined();
    expect(appCache.get("search:da-lat")).toEqual({ destinations: [] });
  });
});
