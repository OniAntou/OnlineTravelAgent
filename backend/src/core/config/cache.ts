import type { NextFunction, Request, Response } from "express";
import NodeCache from "node-cache";

// 5 minutes default TTL
export const appCache = new NodeCache({ stdTTL: 300 });

export const BOOTSTRAP_BASE_KEY = "bootstrapBase";

export function bootstrapResponseCacheKey(userId?: string) {
  return `bootstrap_${userId || "public"}`;
}

export function invalidateBootstrapCache() {
  const responseKeys = appCache
    .keys()
    .filter((key) => key.startsWith("bootstrap_"));
  appCache.del([BOOTSTRAP_BASE_KEY, ...responseKeys]);
}

export function invalidateBootstrapUserCache(userId?: string) {
  appCache.del(bootstrapResponseCacheKey(userId));
}

export function invalidateBootstrapBaseCache() {
  invalidateBootstrapCache();
}

export function invalidateBootstrapBaseOnMutation(
  req: Request,
  res: Response,
  next: NextFunction,
) {
  res.on("finish", () => {
    if (req.method !== "GET" && res.statusCode >= 200 && res.statusCode < 400) {
      invalidateBootstrapCache();
    }
  });
  next();
}

export function invalidateBootstrapUserOnMutation(
  req: Request,
  res: Response,
  next: NextFunction,
) {
  res.on("finish", () => {
    if (req.method !== "GET" && res.statusCode >= 200 && res.statusCode < 400) {
      invalidateBootstrapUserCache(req.userId);
    }
  });
  next();
}
