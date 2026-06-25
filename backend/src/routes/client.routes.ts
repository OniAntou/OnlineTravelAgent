import { Router } from "express";
import { clientController } from "../controllers/client.controller.js";
import { validate } from "../middlewares/validate.js";
import { optionalAuth, clientAuth } from "../middlewares/auth.js";
import {
  bookTripSchema,
  bookFlightSchema,
  documentSchema,
  bookHotelSchema,
  bookTourSchema,
  customTourSchema,
  reviewSchema,
} from "../schemas/client.schema.js";

export const clientRouter = Router();

clientRouter.get("/bootstrap", optionalAuth, clientController.getBootstrap);

// Favorites
clientRouter.get("/favorites", clientAuth, clientController.getFavorites);
clientRouter.patch("/destinations/:id/favorite", clientAuth, clientController.updateFavorite);

// Promo Codes
clientRouter.get("/promo-codes/check", clientAuth, clientController.checkPromoCode);

// Trips
clientRouter.get("/trips", clientAuth, clientController.getTrips);
clientRouter.get("/trips/:id/schedule", optionalAuth, clientController.getTripSchedule);
clientRouter.post("/trips/book", clientAuth, validate(bookTripSchema), clientController.bookTrip);
clientRouter.post("/trips/book-flight", clientAuth, validate(bookFlightSchema), clientController.bookFlightTrip);
clientRouter.post("/trips/custom-tour", clientAuth, validate(customTourSchema), clientController.createCustomTour);
clientRouter.post("/trips/:id/cancel", clientAuth, clientController.cancelTrip);

// Flights
clientRouter.get("/flights/search", clientController.searchFlights);

// Documents
clientRouter.get("/documents", clientController.getDocuments);
clientRouter.post("/documents", validate(documentSchema), clientController.createDocument);
clientRouter.delete("/documents/:id", clientController.deleteDocument);

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
