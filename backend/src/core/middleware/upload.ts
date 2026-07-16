import multer from "multer";
import path from "path";
import { fileURLToPath } from "url";

const MAX_FILE_SIZE = 10 * 1024 * 1024; // 10MB
const allowedMimeTypes = new Map<string, Set<string>>([
  ["image/jpeg", new Set([".jpg", ".jpeg"])],
  ["image/png", new Set([".png"])],
  ["image/gif", new Set([".gif"])],
  ["image/webp", new Set([".webp"])],
]);

export class UploadValidationError extends Error {}

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// The legacy directory remains readable at /uploads so existing database
// values still render. New uploads are kept in memory and sent to Storage.
export const UPLOAD_DIR = process.env.UPLOAD_DIR
  ? path.resolve(process.env.UPLOAD_DIR)
  : path.resolve(__dirname, "../../public/uploads");

export function getSafeImageExtension(file: Express.Multer.File): string | null {
  const ext = path.extname(file.originalname).toLowerCase();
  const allowedExtensions = allowedMimeTypes.get(file.mimetype);
  if (!allowedExtensions?.has(ext)) return null;
  return ext === ".jpeg" ? ".jpg" : ext;
}

const fileFilter = (req: Express.Request, file: Express.Multer.File, cb: multer.FileFilterCallback) => {
  if (getSafeImageExtension(file)) {
    cb(null, true);
  } else {
    cb(
      new UploadValidationError("File type not allowed. Allowed: jpeg, jpg, png, gif, webp"),
    );
  }
};

export const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: MAX_FILE_SIZE,
    files: 1,
    fields: 20,
    fieldNameSize: 100,
  },
  fileFilter,
});
