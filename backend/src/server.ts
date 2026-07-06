import { Server as SocketIOServer } from "socket.io";
import jwt from "jsonwebtoken";
import prisma from "./config/prisma.js";
import { env } from "./config/env.js";
import { app } from "./app.js";

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
      methods: ["GET", "POST"]
    }
  });

  io.on("connection", (socket) => {
    socket.on("join_trip_room", async (payload) => {
      const tripId = typeof payload === "string" ? payload : payload?.tripId;
      const token = typeof payload === "object" ? payload?.token : undefined;
      if (!tripId || !token) return;

      try {
        const decoded = jwt.verify(token, env.jwtSecret) as { userId: string };
        const trip = await prisma.trip.findUnique({
          where: { id: tripId },
          select: { userId: true },
        });
        if (trip?.userId === decoded.userId) {
          socket.join(`trip_${tripId}`);
        }
      } catch {
        // Ignore unauthorized room join attempts.
      }
    });
    socket.on("join_tour_room", (tourId) => {
      socket.join(`tour_${tourId}`);
    });
  });

  app.set("io", io);
});

// Graceful shutdown
async function shutdown() {
  console.log("\nShutting down gracefully...");
  server.close();
  await prisma.$disconnect();
  console.log("Database disconnected. Goodbye!");
  process.exit(0);
}

process.on("SIGINT", shutdown);
process.on("SIGTERM", shutdown);
