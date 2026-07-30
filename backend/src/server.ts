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
async function shutdown(exitCode: number = 0) {
  logger.info("\nShutting down gracefully...");
  stopPendingImageCleanup();
  server.close();
  await prisma.$disconnect();
  logger.info("Database disconnected. Goodbye!");
  process.exit(exitCode);
}

process.on("SIGINT", () => shutdown(0));
process.on("SIGTERM", () => shutdown(0));

process.on("uncaughtException", (err) => {
  logger.error("UNCAUGHT EXCEPTION! 💥 Shutting down...");
  if (err instanceof Error) {
    logger.error(`${err.name}: ${err.message}\n${err.stack}`);
  } else {
    logger.error(err);
  }
  shutdown(1);
});

process.on("unhandledRejection", (err) => {
  logger.error("UNHANDLED REJECTION! 💥 Shutting down...");
  if (err instanceof Error) {
    logger.error(`${err.name}: ${err.message}\n${err.stack}`);
  } else {
    logger.error(err);
  }
  shutdown(1);
});
