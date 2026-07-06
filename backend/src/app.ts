import cors from "cors";
import express from "express";
import helmet from "helmet";
import multer from "multer";
import { fileURLToPath } from "url";
import { dirname, join } from "path";
import { routes } from "./routes/index.js";
import { Request, Response, NextFunction } from "express";
import { env } from "./config/env.js";
import { UPLOAD_DIR, UploadValidationError } from "./middlewares/upload.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const adminDir = join(__dirname, "../admin");
const partnerDir = join(__dirname, "../partner");

export const app = express();

app.set("trust proxy", env.trustProxy);

// Security headers
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'", "'unsafe-inline'", "cdn.tailwindcss.com"],
      scriptSrcAttr: ["'unsafe-inline'"],
      styleSrc: ["'self'", "'unsafe-inline'", "fonts.googleapis.com", "cdnjs.cloudflare.com"],
      fontSrc: ["'self'", "fonts.gstatic.com", "cdnjs.cloudflare.com"],
      imgSrc: ["'self'", "data:", "blob:"],
    },
  },
}));

// CORS whitelist
app.use(cors({
  origin: (origin, callback) => {
    if (!origin || env.corsOrigins.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error("Not allowed by CORS"));
    }
  },
}));

// Request body size limit
app.use(express.json({ limit: "1mb" }));

// Redirect root to /admin
app.get("/", (req, res) => {
  res.redirect("/admin");
});

// Serve admin panel at /admin (no auth for static files, UI handles login)
app.use("/admin", express.static(adminDir));
app.use("/partner", express.static(partnerDir));

// Serve uploads
app.use("/uploads", express.static(UPLOAD_DIR));

app.get("/health", (_, res) => {
  res.json({ ok: true });
});

// Mount all API routes
app.use("/api", routes);

// Global error handling middleware
app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
  if (err instanceof multer.MulterError || err instanceof UploadValidationError) {
    res.status(400).json({ message: err.message });
    return;
  }

  console.error("Unhandled error:", err);
  res.status(500).json({ message: "Internal server error" });
});
