import { Server as SocketIOServer } from "socket.io";
import jwt from "jsonwebtoken";
import { z } from "zod";
import prisma from "./infrastructure/database/prisma.js";
import { env } from "./core/config/env.js";
import { app } from "./app.js";
import { memoryDb } from "./infrastructure/fallback/memory-db.js";
import { startPendingImageCleanup } from "./core/storage/supabase-storage.js";

memoryDb.init();

type SocketAuthPayload = {
  token?: unknown;
};

function extractSocketToken(payload: unknown): string | null {
  if (!payload || typeof payload !== "object") return null;
  const token = (payload as SocketAuthPayload).token;
  return typeof token === "string" && token.trim() ? token.trim() : null;
}

function verifySocketToken(payload: unknown): { userId: string } | null {
  const token = extractSocketToken(payload);
  if (!token) return null;

  try {
    return jwt.verify(token, env.jwtSecret) as { userId: string };
  } catch {
    return null;
  }
}

const server = app.listen(env.port, () => {
  console.log(`\n==============================================`);
  console.log(`Backend running at http://localhost:${env.port}`);
  console.log(`==============================================`);
  console.log(`Admin Portal:   http://localhost:${env.port}/admin`);
  console.log(`Partner Portal: http://localhost:${env.port}/partner`);
  console.log(`==============================================`);

  // Initialize Socket.IO
  const io = new SocketIOServer(server, {
    cors: {
      origin: env.corsOrigins,
      methods: ["GET", "POST"],
    },
  });

  io.on("connection", (socket) => {
    socket.on("join_trip_room", async (payload) => {
      try {
        const parsed = z.object({ tripId: z.string(), token: z.string() }).safeParse(payload);
        if (!parsed.success) return;
        const { tripId, token } = parsed.data;

        const decoded = jwt.verify(token, env.jwtSecret) as { userId: string };
        const trip = await prisma.trip.findUnique({
          where: { id: tripId },
          select: { userId: true },
        });
        if (trip?.userId === decoded.userId) {
          socket.join(`trip_${tripId}`);
        }
      } catch (err) {
        console.error("Error in join_trip_room:", err);
      }
    });
    socket.on("leave_trip_room", (tripId) => {
      if (typeof tripId === "string" && tripId) {
        socket.leave(`trip_${tripId}`);
      }
    });
    socket.on("join_tour_room", async (payload) => {
      try {
        const parsed = z.object({ tourId: z.string(), token: z.string() }).safeParse(payload);
        if (!parsed.success) return;
        const { tourId, token } = parsed.data;

        const decoded = jwt.verify(token, env.jwtSecret) as { userId: string };
        const hasPurchased = await prisma.trip.findFirst({
          where: {
            userId: decoded.userId,
            tourPackageId: tourId,
            status: { not: "CANCELLED" }
          },
          select: { id: true },
        });
        if (hasPurchased) {
          socket.join(`tour_${tourId}`);
        }
      } catch (err) {
        console.error("Error in join_tour_room:", err);
      }
    });
    socket.on("leave_tour_room", (tourId) => {
      if (typeof tourId === "string" && tourId) {
        socket.leave(`tour_${tourId}`);
      }
    });
  });

  app.set("io", io);
});

const stopPendingImageCleanup = startPendingImageCleanup();

// Graceful shutdown
async function shutdown() {
  console.log("\nShutting down gracefully...");
  stopPendingImageCleanup();
  server.close();
  await prisma.$disconnect();
  console.log("Database disconnected. Goodbye!");
  process.exit(0);
}

process.on("SIGINT", shutdown);
process.on("SIGTERM", shutdown);
