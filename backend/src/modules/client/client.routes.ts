import { Router } from "express";
import { clientController } from "./client.controller.js";
import { validate } from "../../core/middleware/validate.js";
import { optionalAuth, clientAuth } from "../../core/middleware/auth.js";
import {
  bookTripSchema,
  bookFlightSchema,
  documentSchema,
  bookHotelSchema,
  bookTourSchema,
  reviewSchema,
} from "./client.schema.js";
import { invalidateBootstrapBaseOnMutation } from "../../core/config/cache.js";

export const clientRouter = Router();

// Reviews change aggregate rating/count data embedded in the bootstrap base.
clientRouter.use("/reviews", invalidateBootstrapBaseOnMutation);

clientRouter.get("/bootstrap", optionalAuth, clientController.getBootstrap);

// Global Search
clientRouter.get("/search", clientController.globalSearch);

// Favorites
clientRouter.get("/favorites", clientAuth, clientController.getFavorites);
clientRouter.patch("/destinations/:id/favorite", clientAuth, clientController.updateFavorite);

// Promo Codes
clientRouter.get("/promo-codes/check", clientAuth, clientController.checkPromoCode);

// Trips
clientRouter.get("/trips", clientAuth, clientController.getTrips);
clientRouter.get("/trips/schedules", clientAuth, clientController.getTripSchedulesBatch);
clientRouter.get("/trips/:id/schedule", clientAuth, clientController.getTripSchedule);
clientRouter.post("/trips/book", clientAuth, validate(bookTripSchema), clientController.bookTrip);
clientRouter.post("/trips/book-flight", clientAuth, validate(bookFlightSchema), clientController.bookFlightTrip);
clientRouter.post("/trips/:id/cancel", clientAuth, clientController.cancelTrip);

// Flights
clientRouter.get("/flights/search", clientController.searchFlights);

// Documents
clientRouter.get("/documents", clientAuth, clientController.getDocuments);
clientRouter.post("/documents", clientAuth, validate(documentSchema), clientController.createDocument);
clientRouter.delete("/documents/:id", clientAuth, clientController.deleteDocument);

// Hotels
clientRouter.get("/hotels", clientController.getHotels);
clientRouter.get("/hotels/search", clientController.searchHotels);
clientRouter.get("/hotels/:id", clientController.getHotelById);
clientRouter.post("/hotels/book", clientAuth, validate(bookHotelSchema), clientController.bookHotel);

// Tours
clientRouter.get("/tours", clientController.getTours);
clientRouter.get("/tours/:id", clientController.getTourById);
clientRouter.get("/tours/:id/schedule", clientController.getTourSchedule);
clientRouter.post("/tours/book", clientAuth, validate(bookTourSchema), clientController.bookTour);

// Reviews
clientRouter.get("/reviews", clientController.getReviews);
clientRouter.post("/reviews", clientAuth, validate(reviewSchema), clientController.createReview);
clientRouter.delete("/reviews/:id", clientAuth, clientController.deleteReview);
