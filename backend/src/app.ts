import cors from "cors";
import express from "express";
import { Prisma } from "@prisma/client";
import helmet from "helmet";
import multer from "multer";
import compression from "compression";
import winston from "winston";
import prisma from "./config/prisma.js";

export const logger = winston.createLogger({
  level: "info",
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [new winston.transports.Console()],
});
import { fileURLToPath } from "url";
import { dirname, join } from "path";
import { routes } from "./routes/index.js";
import { Request, Response, NextFunction } from "express";
import { env } from "./config/env.js";
import { UPLOAD_DIR, UploadValidationError } from "./middlewares/upload.js";
import { adminAuth } from "./middlewares/auth.js";
import { panelRateLimiter, panelStaticHeaders } from "./middlewares/panel.js";
import { PersistentDataUnavailableError } from "./config/data-availability.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const adminDir = join(__dirname, "../admin");
const partnerDir = join(__dirname, "../partner");

export const app = express();

app.set("trust proxy", env.trustProxy);
app.set("json replacer", (_key: string, value: unknown) =>
  value instanceof Prisma.Decimal ? value.toNumber() : value,
);

// Nén phản hồi HTTP để tối ưu payload
app.use(compression());

// Security headers
app.use(
  helmet({
    contentSecurityPolicy: {
      directives: {
        defaultSrc: ["'self'"],
        scriptSrc: ["'self'", "'unsafe-inline'", "cdn.tailwindcss.com"],
        scriptSrcAttr: ["'unsafe-inline'"],
        styleSrc: [
          "'self'",
          "'unsafe-inline'",
          "fonts.googleapis.com",
          "cdnjs.cloudflare.com",
        ],
        fontSrc: ["'self'", "fonts.gstatic.com", "cdnjs.cloudflare.com"],
        imgSrc: ["'self'", "data:", "blob:"],
      },
    },
  }),
);

// CORS whitelist
app.use(
  cors({
    origin: (origin, callback) => {
      if (!origin || env.corsOrigins.includes(origin)) {
        callback(null, true);
      } else {
        callback(new Error("Not allowed by CORS"));
      }
    },
  }),
);

// Request body size limit
app.use(express.json({ limit: "1mb" }));

// Redirect root to /admin
app.get("/", (req, res) => {
  res.redirect("/admin");
});

// Serve admin/partner panels with rate limit and no-cache headers.
// Optional REQUIRE_ADMIN_BASIC_AUTH=true adds HTTP Basic Auth before static assets.
const adminStatic = [
  panelRateLimiter,
  panelStaticHeaders,
  express.static(adminDir),
];
const partnerStatic = [
  panelRateLimiter,
  panelStaticHeaders,
  express.static(partnerDir),
];

if (process.env.REQUIRE_ADMIN_BASIC_AUTH === "true") {
  app.use("/admin", adminAuth, ...adminStatic);
} else {
  app.use("/admin", ...adminStatic);
}

app.use("/partner", ...partnerStatic);

// Serve uploads
app.use("/uploads", express.static(UPLOAD_DIR));

app.get("/health", async (_, res) => {
  try {
    await prisma.$queryRaw`SELECT 1`;
    res.json({ ok: true, db: "connected" });
  } catch (error) {
    logger.error("Health check failed", { error });
    res.status(503).json({ ok: false, db: "disconnected" });
  }
});

import rateLimit from "express-rate-limit";

const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  limit: 200, // Limit each IP to 200 requests per windowMs
  standardHeaders: "draft-7", // draft-6: `RateLimit-*` headers; draft-7: combined `RateLimit` header
  legacyHeaders: false, // Disable the `X-RateLimit-*` headers
});

// Mount all API routes
app.use("/api", apiLimiter, routes);

import { ZodError } from "zod";

// Global error handling middleware
app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
  if (err instanceof PersistentDataUnavailableError) {
    res.status(503).json({ message: err.message });
    return;
  }

  if (
    err instanceof multer.MulterError ||
    err instanceof UploadValidationError
  ) {
    res.status(400).json({ message: err.message });
    return;
  }

  if (err instanceof ZodError) {
    res.status(400).json({ message: "Validation error", errors: err.issues });
    return;
  }

  logger.error("Unhandled error", { error: err.message, stack: err.stack });
  res.status(500).json({ message: "Internal server error" });
});
