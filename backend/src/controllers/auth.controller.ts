import { Request, Response } from "express";
import { Role } from "@prisma/client";
import prisma from "../config/prisma.js";
import { passwordService } from "../services/password.service.js";
import { tokenService } from "../services/token.service.js";
import { asyncHandler } from "../utils/asyncHandler.js";

async function buildAuthResponse(user: { id: string; name: string; email: string; role: Role; password: string; createdAt: Date; updatedAt: Date }) {
  const { password: _, ...userWithoutPassword } = user;
  const tokens = await tokenService.issueTokenPair({ id: user.id, role: user.role });

  return {
    user: userWithoutPassword,
    token: tokens.accessToken,
    refreshToken: tokens.refreshToken,
    expiresIn: tokens.expiresIn,
  };
}

export const authController = {
  login: asyncHandler(async (req: Request, res: Response) => {
    const { email, password } = req.body;

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

    res.json(await buildAuthResponse(user));
  }),

  register: asyncHandler(async (req: Request, res: Response) => {
    const { name, email, password } = req.body;

    const existing = await prisma.user.findUnique({ where: { email } });
    if (existing) {
      res.status(409).json({ message: "Email already exists" });
      return;
    }

    const hashedPassword = await passwordService.hash(password);
    const user = await prisma.user.create({
      data: { name, email, password: hashedPassword },
    });

    res.status(201).json(await buildAuthResponse(user));
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

    const user = await prisma.user.update({
      where: { id: userId },
      data: { role: "PARTNER" },
    });

    res.json(await buildAuthResponse(user));
  }),
};
