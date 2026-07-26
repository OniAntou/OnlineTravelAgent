import prisma from "./infrastructure/database/prisma.js";
import { env } from "./core/config/env.js";
import { app, logger } from "./app.js";
import { memoryDb } from "./infrastructure/fallback/memory-db.js";
import { startPendingImageCleanup } from "./core/storage/supabase-storage.js";
import { initializeSocket } from "./sockets/socket.manager.js";

memoryDb.init();

const server = app.listen(env.port, () => {
  logger.info(`\n==============================================`);
  logger.info(`Backend running at http://localhost:${env.port}`);
  logger.info(`==============================================`);
  logger.info(`Admin Portal:   http://localhost:${env.port}/admin`);
  logger.info(`Partner Portal: http://localhost:${env.port}/partner`);
  logger.info(`==============================================`);

  // Initialize Socket.IO using the separated manager
  const io = initializeSocket(server);
  app.set("io", io);
});

const stopPendingImageCleanup = startPendingImageCleanup();

// Graceful shutdown
async function shutdown() {
  logger.info("\nShutting down gracefully...");
  stopPendingImageCleanup();
  server.close();
  await prisma.$disconnect();
  logger.info("Database disconnected. Goodbye!");
  process.exit(0);
}

process.on("SIGINT", shutdown);
process.on("SIGTERM", shutdown);
