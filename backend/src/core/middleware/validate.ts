import express from "express";
import { z } from "zod";

export const validate = (schema: z.ZodSchema) => (req: express.Request, res: express.Response, next: express.NextFunction) => {
  const parsed = schema.safeParse(req.body);
  if (!parsed.success) {
    const issues = parsed.error.issues;
    res.status(400).json({
      message: issues[0]?.message ?? "Invalid request body",
      errors: issues,
    });
    return;
  }
  req.body = parsed.data;
  next();
};