import jwt from "jsonwebtoken";
import prisma from "../infrastructure/database/prisma.js";
import { env } from "../core/config/env.js";
import { logger } from "../app.js";

export class SocketService {
  /**
   * Verify token and check if the user has access to the trip.
   */
  static async verifyUserCanJoinTrip(tripId: string, token: string): Promise<boolean> {
    try {
      const decoded = jwt.verify(token, env.jwtSecret) as { userId: string };
      const trip = await prisma.trip.findUnique({
        where: { id: tripId },
        select: { userId: true },
      });
      return trip?.userId === decoded.userId;
    } catch (err) {
      logger.error("Error verifying trip access for socket:", { tripId, error: err });
      return false;
    }
  }

  /**
   * Verify token and check if the user has purchased the tour package.
   */
  static async verifyUserCanJoinTour(tourId: string, token: string): Promise<boolean> {
    try {
      const decoded = jwt.verify(token, env.jwtSecret) as { userId: string };
      const hasPurchased = await prisma.trip.findFirst({
        where: {
          userId: decoded.userId,
          tourPackageId: tourId,
          status: { not: "CANCELLED" },
        },
        select: { id: true },
      });
      return !!hasPurchased;
    } catch (err) {
      logger.error("Error verifying tour access for socket:", { tourId, error: err });
      return false;
    }
  }
}
