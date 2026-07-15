import crypto from "crypto";
import jwt from "jsonwebtoken";
import { Role } from "@prisma/client";
import prisma from "../infrastructure/database/prisma.js";
import { env } from "../core/config/env.js";
import { memoryDb } from "../infrastructure/fallback/memory-db.js";
import { assertMemoryFallbackEnabled } from "../core/config/data-availability.js";

const ACCESS_TOKEN_TTL = "15m";
const REFRESH_TOKEN_TTL_MS = 30 * 24 * 60 * 60 * 1000;
const ACCESS_TOKEN_EXPIRES_IN_SECONDS = 15 * 60;

type AuthUser = {
  id: string;
  role: Role;
};

type TokenPairRecord = {
  accessToken: string;
  refreshToken: string;
  expiresIn: number;
  tokenHash: string;
  expiresAt: Date;
};

function hashToken(token: string): string {
  return crypto.createHash("sha256").update(token).digest("hex");
}

function createRefreshTokenValue(): string {
  return crypto.randomBytes(48).toString("base64url");
}

function signAccessToken(user: AuthUser): string {
  return jwt.sign({ userId: user.id, role: user.role }, env.jwtSecret, {
    expiresIn: ACCESS_TOKEN_TTL,
  });
}

function buildTokenPair(user: AuthUser): TokenPairRecord {
  const refreshToken = createRefreshTokenValue();
  return {
    accessToken: signAccessToken(user),
    refreshToken,
    expiresIn: ACCESS_TOKEN_EXPIRES_IN_SECONDS,
    tokenHash: hashToken(refreshToken),
    expiresAt: new Date(Date.now() + REFRESH_TOKEN_TTL_MS),
  };
}

function publicTokenPair(pair: TokenPairRecord) {
  return {
    accessToken: pair.accessToken,
    refreshToken: pair.refreshToken,
    expiresIn: pair.expiresIn,
  };
}

async function dbAvailable(): Promise<boolean> {
  try {
    await prisma.$queryRaw`SELECT 1`;
    return true;
  } catch {
    return false;
  }
}

export const tokenService = {
  accessTokenExpiresInSeconds: ACCESS_TOKEN_EXPIRES_IN_SECONDS,

  async issueTokenPair(user: AuthUser) {
    const pair = buildTokenPair(user);

    const useMem = !(await dbAvailable());
    if (useMem) {
      assertMemoryFallbackEnabled();
      memoryDb.createRefreshToken(user.id, pair.tokenHash, pair.expiresAt);
    } else {
      await prisma.refreshToken.create({
        data: {
          userId: user.id,
          tokenHash: pair.tokenHash,
          expiresAt: pair.expiresAt,
        },
      });
    }

    return publicTokenPair(pair);
  },

  async rotateRefreshToken(refreshToken: string) {
    const tokenHash = hashToken(refreshToken);
    const useMem = !(await dbAvailable());

    if (useMem) {
      assertMemoryFallbackEnabled();
      const stored = memoryDb.findRefreshToken(tokenHash);
      if (!stored || stored.revokedAt || stored.expiresAt < new Date()) {
        return null;
      }
      memoryDb.revokeRefreshToken(tokenHash);
      const user = memoryDb.findUserById(stored.userId);
      if (!user) return null;
      return this.issueTokenPair({ id: user.id, role: user.role as Role });
    }

    return prisma.$transaction(async (tx) => {
      const now = new Date();
      const stored = await tx.refreshToken.findUnique({
        where: { tokenHash },
        include: { user: true },
      });

      if (!stored || stored.revokedAt || stored.expiresAt <= now) {
        return null;
      }

      const revoked = await tx.refreshToken.updateMany({
        where: {
          id: stored.id,
          revokedAt: null,
          expiresAt: { gt: now },
        },
        data: { revokedAt: now },
      });
      if (revoked.count !== 1) return null;

      const user = { id: stored.user.id, role: stored.user.role };
      const pair = buildTokenPair(user);
      await tx.refreshToken.create({
        data: {
          userId: user.id,
          tokenHash: pair.tokenHash,
          expiresAt: pair.expiresAt,
        },
      });
      return publicTokenPair(pair);
    });
  },

  async revokeRefreshToken(refreshToken: string) {
    const tokenHash = hashToken(refreshToken);
    const useMem = !(await dbAvailable());

    if (useMem) {
      assertMemoryFallbackEnabled();
      return memoryDb.revokeRefreshToken(tokenHash);
    }

    const stored = await prisma.refreshToken.findUnique({
      where: { tokenHash },
    });
    if (!stored || stored.revokedAt) return false;

    await prisma.refreshToken.update({
      where: { id: stored.id },
      data: { revokedAt: new Date() },
    });
    return true;
  },

  async revokeAllForUser(userId: string) {
    const useMem = !(await dbAvailable());

    if (useMem) {
      assertMemoryFallbackEnabled();
      memoryDb.revokeAllRefreshTokens(userId);
      return;
    }

    await prisma.refreshToken.updateMany({
      where: { userId, revokedAt: null },
      data: { revokedAt: new Date() },
    });
  },
};
