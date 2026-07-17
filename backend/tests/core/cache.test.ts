import { afterEach, describe, expect, it } from "vitest";
import {
  appCache,
  BOOTSTRAP_BASE_KEY,
  invalidateBootstrapCache,
  invalidateBootstrapUserCache,
} from "../../src/core/config/cache.js";

describe("bootstrap cache invalidation", () => {
  afterEach(() => {
    appCache.flushAll();
  });

  it("removes every bootstrap response when shared catalogue data changes", () => {
    appCache.set(BOOTSTRAP_BASE_KEY, { destinations: [] });
    appCache.set("bootstrap_public", { destinations: [] });
    appCache.set("bootstrap_user-1", { destinations: [] });
    appCache.set("search:da-lat", { destinations: [] });

    invalidateBootstrapCache();

    expect(appCache.get(BOOTSTRAP_BASE_KEY)).toBeUndefined();
    expect(appCache.get("bootstrap_public")).toBeUndefined();
    expect(appCache.get("bootstrap_user-1")).toBeUndefined();
    expect(appCache.get("search:da-lat")).toEqual({ destinations: [] });
  });

  it("removes only the affected user's response when user-owned data changes", () => {
    appCache.set(BOOTSTRAP_BASE_KEY, { destinations: [] });
    appCache.set("bootstrap_public", { destinations: [] });
    appCache.set("bootstrap_user-1", { destinations: [] });
    appCache.set("bootstrap_user-2", { destinations: [] });

    invalidateBootstrapUserCache("user-1");

    expect(appCache.get(BOOTSTRAP_BASE_KEY)).toEqual({ destinations: [] });
    expect(appCache.get("bootstrap_public")).toEqual({ destinations: [] });
    expect(appCache.get("bootstrap_user-1")).toBeUndefined();
    expect(appCache.get("bootstrap_user-2")).toEqual({ destinations: [] });
  });
});
