import multer from "multer";
import path from "path";
import fs from "fs";
import crypto from "crypto";
import { fileURLToPath } from "url";

const MAX_FILE_SIZE = 10 * 1024 * 1024; // 10MB
const allowedMimeTypes = new Map<string, Set<string>>([
  ["image/jpeg", new Set([".jpg", ".jpeg"])],
  ["image/png", new Set([".png"])],
  ["image/gif", new Set([".gif"])],
  ["image/webp", new Set([".webp"])],
  ["application/pdf", new Set([".pdf"])],
  ["application/msword", new Set([".doc"])],
  [
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
    new Set([".docx"]),
  ],
]);

export class UploadValidationError extends Error {}

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export const UPLOAD_DIR = process.env.UPLOAD_DIR
  ? path.resolve(process.env.UPLOAD_DIR)
  : path.resolve(__dirname, "../../public/uploads");

function getSafeExtension(file: Express.Multer.File): string | null {
  const ext = path.extname(file.originalname).toLowerCase();
  const allowedExtensions = allowedMimeTypes.get(file.mimetype);
  if (!allowedExtensions?.has(ext)) return null;
  return ext === ".jpeg" ? ".jpg" : ext;
}

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    if (!fs.existsSync(UPLOAD_DIR)) {
      fs.mkdirSync(UPLOAD_DIR, { recursive: true });
    }
    cb(null, UPLOAD_DIR);
  },
  filename: (req, file, cb) => {
    const ext = getSafeExtension(file);
    if (!ext) {
      cb(new UploadValidationError("File type not allowed"), "");
      return;
    }

    cb(null, `${file.fieldname}-${Date.now()}-${crypto.randomUUID()}${ext}`);
  },
});

const fileFilter = (req: Express.Request, file: Express.Multer.File, cb: multer.FileFilterCallback) => {
  if (getSafeExtension(file)) {
    cb(null, true);
  } else {
    cb(
      new UploadValidationError("File type not allowed. Allowed: jpeg, jpg, png, gif, webp, pdf, doc, docx"),
    );
  }
};

export const upload = multer({
  storage,
  limits: {
    fileSize: MAX_FILE_SIZE,
    files: 1,
    fields: 20,
    fieldNameSize: 100,
  },
  fileFilter,
});
