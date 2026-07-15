import { Request, Response } from "express";
import { Role } from "@prisma/client";
import prisma from "../infrastructure/database/prisma.js";
import { passwordService } from "../services/password.service.js";
import { tokenService } from "../services/token.service.js";
import { asyncHandler } from "../core/utils/asyncHandler.js";
import { memoryDb } from "../infrastructure/fallback/memory-db.js";
import { assertMemoryFallbackEnabled } from "../core/config/data-availability.js";

type SafeUser = { id: string; name: string; email: string; role: Role; createdAt: Date; updatedAt: Date };

async function buildAuthResponse(user: SafeUser) {
  const tokens = await tokenService.issueTokenPair({ id: user.id, role: user.role });

  return {
    user,
    token: tokens.accessToken,
    refreshToken: tokens.refreshToken,
    expiresIn: tokens.expiresIn,
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

export const authController = {
  login: asyncHandler(async (req: Request, res: Response) => {
    const { email, password } = req.body;

    const useMem = !(await dbAvailable());

    if (useMem) {
      assertMemoryFallbackEnabled();
      const user = memoryDb.findUserByEmail(email);
      if (!user) {
        res.status(401).json({ message: "Invalid email or password" });
        return;
      }
      const passwordValid = await passwordService.verify(password, user.password);
      if (!passwordValid) {
        res.status(401).json({ message: "Invalid email or password" });
        return;
      }
      const { password: _, ...safeUser } = user;
      res.json(await buildAuthResponse(safeUser as SafeUser));
      return;
    }

    const user = await prisma.user.findUnique({ where: { email } });
    if (!user) {
      res.status(401).json({ message: "Invalid email or password" });
      return;
    }

    const passwordValid = await passwordService.verify(password, user.password);
    if (!passwordValid) {
      res.status(401).json({ message: "Invalid email or password" });
      return;
    }

    if (passwordService.shouldMigrate(user.password)) {
      const bcryptHash = await passwordService.hash(password);
      await prisma.user.update({
        where: { id: user.id },
        data: { password: bcryptHash },
      });
    }

    const { password: _, ...safeUser } = user;
    res.json(await buildAuthResponse(safeUser as SafeUser));
  }),

  register: asyncHandler(async (req: Request, res: Response) => {
    const { name, email, password } = req.body;

    const useMem = !(await dbAvailable());

    if (useMem) {
      assertMemoryFallbackEnabled();
      const existing = memoryDb.findUserByEmail(email);
      if (existing) {
        res.status(409).json({ message: "Email already exists" });
        return;
      }
      const hashedPassword = await passwordService.hash(password);
      const user = memoryDb.createUser({ name, email, password: hashedPassword });
      const { password: _, ...safeUser } = user;
      res.status(201).json(await buildAuthResponse(safeUser as SafeUser));
      return;
    }

    const existing = await prisma.user.findUnique({ where: { email } });
    if (existing) {
      res.status(409).json({ message: "Email already exists" });
      return;
    }

    const hashedPassword = await passwordService.hash(password);
    const user = await prisma.user.create({
      data: { name, email, password: hashedPassword },
    });

    const { password: _, ...safeUser } = user;
    res.status(201).json(await buildAuthResponse(safeUser as SafeUser));
  }),

  refresh: asyncHandler(async (req: Request, res: Response) => {
    const refreshToken = typeof req.body?.refreshToken === "string" ? req.body.refreshToken.trim() : "";
    if (!refreshToken) {
      res.status(400).json({ message: "refreshToken is required" });
      return;
    }

    const tokens = await tokenService.rotateRefreshToken(refreshToken);
    if (!tokens) {
      res.status(401).json({ message: "Invalid or expired refresh token" });
      return;
    }

    res.json({
      token: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      expiresIn: tokens.expiresIn,
    });
  }),

  logout: asyncHandler(async (req: Request, res: Response) => {
    const refreshToken = typeof req.body?.refreshToken === "string" ? req.body.refreshToken.trim() : "";
    if (refreshToken) {
      await tokenService.revokeRefreshToken(refreshToken);
    }

    res.json({ ok: true });
  }),

  becomePartner: asyncHandler(async (req: Request, res: Response) => {
    const userId = req.userId;
    if (!userId) {
      res.status(401).json({ message: "Unauthorized" });
      return;
    }
    if (process.env.ALLOW_SELF_PARTNER_SIGNUP !== "true") {
      res.status(403).json({ message: "Partner signup requires admin approval" });
      return;
    }

    const useMem = !(await dbAvailable());

    if (useMem) {
      assertMemoryFallbackEnabled();
      const user = memoryDb.updateUser(userId, { role: "PARTNER" });
      if (!user) {
        res.status(404).json({ message: "User not found" });
        return;
      }
      const { password: _, ...safeUser } = user;
      res.json(await buildAuthResponse(safeUser as SafeUser));
      return;
    }

    const user = await prisma.user.update({
      where: { id: userId },
      data: { role: "PARTNER" },
    });

    const { password: _, ...safeUser } = user;
    res.json(await buildAuthResponse(safeUser as SafeUser));
  }),
};
