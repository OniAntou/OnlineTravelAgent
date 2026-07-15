import type { NextFunction, Request, Response } from "express";
import NodeCache from "node-cache";

// 5 minutes default TTL
export const appCache = new NodeCache({ stdTTL: 300 });

export const BOOTSTRAP_BASE_KEY = "bootstrapBase";

export function invalidateBootstrapCache() {
  appCache.flushAll();
}

export function invalidateBootstrapCacheOnMutation(
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