import cors from "cors";
import express from "express";
import helmet from "helmet";
import { fileURLToPath } from "url";
import { dirname, join } from "path";
import { Server as SocketIOServer } from "socket.io";
import prisma from "./config/prisma.js";
import { routes } from "./routes/index.js";
import { Request, Response, NextFunction } from "express";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const app = express();
const port = Number.parseInt(process.env.PORT ?? "3000", 10);

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
const allowedOrigins = (process.env.CORS_ORIGINS ?? "http://localhost:3000,http://10.0.2.2:3000,http://localhost:5173").split(",");
app.use(cors({
  origin: (origin, callback) => {
    if (!origin || allowedOrigins.includes(origin)) {
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
app.use("/admin", express.static(join(__dirname, "../admin")));
app.use("/partner", express.static(join(__dirname, "../partner")));

// Serve uploads
app.use("/uploads", express.static(join(__dirname, "../public/uploads")));

app.get("/health", (_, res) => {
  res.json({ ok: true });
});

// Mount all API routes
app.use("/api", routes);

// Global error handling middleware
app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
  console.error("Unhandled error:", err);
  res.status(500).json({ message: "Internal server error" });
});

const server = app.listen(port, async () => {
  console.log(`\n==============================================`);
  console.log(`🚀 Backend running at http://localhost:${port}`);
  console.log(`==============================================`);
  console.log(`👉 Admin Portal:   http://localhost:${port}/admin`);
  console.log(`👉 Partner Portal: http://localhost:${port}/partner`);
  console.log(`👉 Prisma Studio:  http://localhost:5555`);
  console.log(`==============================================`);

  // Initialize Socket.IO
  const io = new SocketIOServer(server, {
    cors: {
      origin: allowedOrigins,
      methods: ["GET", "POST"]
    }
  });

  io.on("connection", (socket) => {
    socket.on("join_trip_room", (tripId) => {
      socket.join(`trip_${tripId}`);
    });
    socket.on("join_tour_room", (tourId) => {
      socket.join(`tour_${tourId}`);
    });
  });

  app.set("io", io);

  try {
    const admin = await prisma.user.findFirst({ where: { role: 'ADMIN' } });
    const partner = await prisma.user.findFirst({ where: { role: 'PARTNER' } });
    
    if (admin || partner) {
      console.log(`[👤 System Users Info]`);
      if (admin) {
        console.log(`👑 ADMIN:   ${admin.email} / password123`);
      }
      if (partner) {
        console.log(`🤝 PARTNER: ${partner.email} / password123`);
      }
      console.log(`==============================================\n`);
    }
  } catch (e) {
    // Ignore db connection issues at startup if they occur
  }
});

// Graceful shutdown
async function shutdown() {
  console.log("\n🔌 Shutting down gracefully...");
  server.close();
  await prisma.$disconnect();
  console.log("✅ Database disconnected. Goodbye!");
  process.exit(0);
}

process.on("SIGINT", shutdown);
process.on("SIGTERM", shutdown);
