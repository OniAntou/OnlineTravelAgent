import { Request, Response } from "express";
import { uploadPublicImage } from "../storage/supabase-storage.js";
import { asyncHandler } from "../utils/asyncHandler.js";

export const imageUploadHandler = asyncHandler(async (req: Request, res: Response) => {
  if (!req.file) {
    res.status(400).json({ error: "No file uploaded" });
    return;
  }

  const url = await uploadPublicImage(req.file);
  res.json({ url });
});
