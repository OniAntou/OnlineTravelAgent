import crypto from "crypto";
import jwt from "jsonwebtoken";
import { Role } from "@prisma/client";
import prisma from "../config/prisma.js";
import { env } from "../config/env.js";
import { memoryDb } from "../store/memory-db.js";
import { assertMemoryFallbackEnabled } from "../config/data-availability.js";

const ACCESS_TOKEN_TTL = "15m";
const REFRESH_TOKEN_TTL_MS = 30 * 24 * 60 * 60 * 1000;
const ACCESS_TOKEN_EXPIRES_IN_SECONDS = 15 * 60;

type AuthUser = {
  id: string;
  role: Role;
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
    const accessToken = signAccessToken(user);
    const refreshToken = createRefreshTokenValue();
    const expiresAt = new Date(Date.now() + REFRESH_TOKEN_TTL_MS);
    const tokenHash = hashToken(refreshToken);

    const useMem = !(await dbAvailable());
    if (useMem) {
      assertMemoryFallbackEnabled();
      memoryDb.createRefreshToken(user.id, tokenHash, expiresAt);
    } else {
      await prisma.refreshToken.create({
        data: {
          userId: user.id,
          tokenHash,
          expiresAt,
        },
      });
    }

    return {
      accessToken,
      refreshToken,
      expiresIn: ACCESS_TOKEN_EXPIRES_IN_SECONDS,
    };
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

    const stored = await prisma.refreshToken.findUnique({
      where: { tokenHash },
      include: { user: true },
    });

    if (!stored || stored.revokedAt || stored.expiresAt < new Date()) {
      return null;
    }

    await prisma.refreshToken.update({
      where: { id: stored.id },
      data: { revokedAt: new Date() },
    });

    return this.issueTokenPair({ id: stored.user.id, role: stored.user.role });
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
