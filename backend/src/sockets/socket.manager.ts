import { Server as SocketIOServer } from "socket.io";
import { Server as HttpServer } from "http";
import { z } from "zod";
import { env } from "../core/config/env.js";
import { logger } from "../app.js";
import { SOCKET_EVENTS, ROOM_PREFIX } from "./socket.constants.js";
import { SocketService } from "./socket.service.js";

export function initializeSocket(server: HttpServer): SocketIOServer {
  const io = new SocketIOServer(server, {
    cors: {
      origin: env.corsOrigins,
      methods: ["GET", "POST"],
    },
  });

  io.on("connection", (socket) => {
    socket.on(SOCKET_EVENTS.JOIN_TRIP_ROOM, async (payload) => {
      try {
        const parsed = z.object({ tripId: z.string(), token: z.string() }).safeParse(payload);
        if (!parsed.success) return;
        
        const { tripId, token } = parsed.data;
        const canJoin = await SocketService.verifyUserCanJoinTrip(tripId, token);
        
        if (canJoin) {
          socket.join(`${ROOM_PREFIX.TRIP}${tripId}`);
        } else {
          socket.emit("error", { message: "Unauthorized or trip not found." });
        }
      } catch (err) {
        logger.error(`Error in ${SOCKET_EVENTS.JOIN_TRIP_ROOM}:`, err);
      }
    });

    socket.on(SOCKET_EVENTS.LEAVE_TRIP_ROOM, (tripId) => {
      if (typeof tripId === "string" && tripId) {
        socket.leave(`${ROOM_PREFIX.TRIP}${tripId}`);
      }
    });

    socket.on(SOCKET_EVENTS.JOIN_TOUR_ROOM, async (payload) => {
      try {
        const parsed = z.object({ tourId: z.string(), token: z.string() }).safeParse(payload);
        if (!parsed.success) return;
        
        const { tourId, token } = parsed.data;
        const canJoin = await SocketService.verifyUserCanJoinTour(tourId, token);
        
        if (canJoin) {
          socket.join(`${ROOM_PREFIX.TOUR}${tourId}`);
        } else {
          socket.emit("error", { message: "Unauthorized or tour not purchased." });
        }
      } catch (err) {
        logger.error(`Error in ${SOCKET_EVENTS.JOIN_TOUR_ROOM}:`, err);
      }
    });

    socket.on(SOCKET_EVENTS.LEAVE_TOUR_ROOM, (tourId) => {
      if (typeof tourId === "string" && tourId) {
        socket.leave(`${ROOM_PREFIX.TOUR}${tourId}`);
      }
    });
  });

  return io;
}
