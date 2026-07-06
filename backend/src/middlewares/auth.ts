import express from "express";
import jwt from "jsonwebtoken";
import crypto from "crypto";
import { env } from "../config/env.js";

// Extract JWT Token
const extractToken = (req: express.Request): string | null => {
  const authHeader = req.headers.authorization;
  if (authHeader && authHeader.startsWith("Bearer ")) {
    return authHeader.substring(7);
  }
  return null;
};

function timingSafeEqual(left: string, right: string): boolean {
  const leftBuffer = Buffer.from(left);
  const rightBuffer = Buffer.from(right);
  return leftBuffer.length === rightBuffer.length && crypto.timingSafeEqual(leftBuffer, rightBuffer);
}

// Client Optional Auth (Sets req.userId if valid, but does not block if missing)
export const optionalAuth = (req: express.Request, res: express.Response, next: express.NextFunction) => {
  const token = extractToken(req);
  if (token) {
    try {
      const decoded = jwt.verify(token, env.jwtSecret) as { userId: string };
      (req as any).userId = decoded.userId;
    } catch (err) {
      // ignore invalid token, proceed as guest
    }
  }
  next();
};

// Client Strict Auth (Requires valid JWT)
export const clientAuth = (req: express.Request, res: express.Response, next: express.NextFunction) => {
  const token = extractToken(req);
  if (!token) {
    res.status(401).json({ message: "Unauthorized - Token missing" });
    return;
  }
  try {
    const decoded = jwt.verify(token, env.jwtSecret) as { userId: string };
    (req as any).userId = decoded.userId;
    next();
  } catch (err) {
    res.status(401).json({ message: "Unauthorized - Invalid token" });
  }
};

// Partner Auth
export const partnerAuth = (req: express.Request, res: express.Response, next: express.NextFunction) => {
  const token = extractToken(req);
  if (!token) {
    res.status(401).json({ message: "Unauthorized - Token missing" });
    return;
  }
  try {
    const decoded = jwt.verify(token, env.jwtSecret) as { userId: string, role: string };
    if (decoded.role !== 'PARTNER' && decoded.role !== 'ADMIN') {
      res.status(403).json({ message: "Forbidden - Partner role required" });
      return;
    }
    (req as any).userId = decoded.userId;
    next();
  } catch (err) {
    res.status(401).json({ message: "Unauthorized - Invalid token" });
  }
};

// Admin Basic Auth Middleware
export const adminAuth = (req: express.Request, res: express.Response, next: express.NextFunction) => {
  const authHeader = req.headers.authorization;
  if (!authHeader) {
    res.status(401).send('Unauthorized');
    return;
  }
  try {
    if (!authHeader.startsWith("Basic ")) {
      res.status(401).send('Unauthorized');
      return;
    }

    const decoded = Buffer.from(authHeader.substring(6), 'base64').toString();
    const separatorIndex = decoded.indexOf(':');
    if (separatorIndex === -1) {
      res.status(401).send('Unauthorized');
      return;
    }

    const user = decoded.slice(0, separatorIndex);
    const pass = decoded.slice(separatorIndex + 1);

    if (user === 'admin' && timingSafeEqual(pass, env.adminPassword)) {
      next();
    } else {
      res.status(401).send('Unauthorized');
    }
  } catch (err) {
    res.status(401).send('Unauthorized');
  }
};
