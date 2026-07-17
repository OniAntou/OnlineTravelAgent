import { Router } from "express";
import { adminController } from "./admin.controller.js";
import { validate } from "../../core/middleware/validate.js";
import {
  adminDestinationSchema,
  adminHotelSchema,
  adminFlightSchema,
  adminTourSchema,
  adminTripSchema,
  adminCategorySchema,
  adminUserSchema,
  adminPartnerCreateSchema,
  adminPartnerUpdateSchema,
  adminRoomSchema,
  adminDocumentSchema,
  adminScheduleTemplateSchema,
} from "./admin.schema.js";

import { upload } from "../../core/middleware/upload.js";
import { imageUploadHandler } from "../../core/http/image-upload-handler.js";
import { invalidateBootstrapBaseOnMutation } from "../../core/config/cache.js";

export const adminRouter = Router();

// Bootstrap only contains catalogue data. Attach invalidation to mutation
// groups that can change that shared payload, not to every admin request.
adminRouter.use("/destinations", invalidateBootstrapBaseOnMutation);
adminRouter.use("/hotels", invalidateBootstrapBaseOnMutation);
adminRouter.use("/flights", invalidateBootstrapBaseOnMutation);
adminRouter.use("/tours", invalidateBootstrapBaseOnMutation);
adminRouter.use("/categories", invalidateBootstrapBaseOnMutation);
adminRouter.use("/trips", invalidateBootstrapBaseOnMutation);
adminRouter.use("/documents", invalidateBootstrapBaseOnMutation);

// Upload
adminRouter.post("/upload", upload.single("file"), imageUploadHandler);

// Stats
adminRouter.get("/stats", adminController.getStats);

// Destinations
adminRouter.get("/destinations", adminController.getDestinations);
adminRouter.post(
  "/destinations",
  validate(adminDestinationSchema),
  adminController.createDestination,
);
adminRouter.put(
  "/destinations/:id",
  validate(adminDestinationSchema),
  adminController.updateDestination,
);
adminRouter.delete("/destinations/:id", adminController.deleteDestination);

// Hotels
adminRouter.get("/hotels", adminController.getHotels);
adminRouter.post(
  "/hotels",
  validate(adminHotelSchema),
  adminController.createHotel,
);
adminRouter.put(
  "/hotels/:id",
  validate(adminHotelSchema),
  adminController.updateHotel,
);
adminRouter.delete("/hotels/:id", adminController.deleteHotel);

// Flights
adminRouter.get("/flights", adminController.getFlights);
adminRouter.post(
  "/flights",
  validate(adminFlightSchema),
  adminController.createFlight,
);
adminRouter.put(
  "/flights/:id",
  validate(adminFlightSchema),
  adminController.updateFlight,
);
adminRouter.delete("/flights/:id", adminController.deleteFlight);

// Tours
adminRouter.get("/tours", adminController.getTours);
adminRouter.post(
  "/tours",
  validate(adminTourSchema),
  adminController.createTour,
);
adminRouter.put(
  "/tours/:id",
  validate(adminTourSchema),
  adminController.updateTour,
);
adminRouter.delete("/tours/:id", adminController.deleteTour);

// Trips
adminRouter.get("/trips", adminController.getTrips);
adminRouter.put(
  "/trips/:id",
  validate(adminTripSchema),
  adminController.updateTrip,
);
adminRouter.delete("/trips/:id", adminController.deleteTrip);
adminRouter.get("/trips/:id/schedule", adminController.getTripSchedule);
adminRouter.put(
  "/trips/:id/schedule/items/:itemId",
  adminController.updateTripScheduleItem,
);
adminRouter.post(
  "/trips/:id/schedule/items",
  adminController.createTripScheduleItem,
);
adminRouter.delete(
  "/trips/:id/schedule/items/:itemId",
  adminController.deleteTripScheduleItem,
);
adminRouter.post(
  "/trips/:id/schedule/days",
  adminController.createTripScheduleDay,
);
adminRouter.put(
  "/trips/:id/schedule/days/:dayId",
  adminController.updateTripScheduleDay,
);
adminRouter.delete(
  "/trips/:id/schedule/days/:dayId",
  adminController.deleteTripScheduleDay,
);
adminRouter.post(
  "/trips/:id/schedule/updates",
  adminController.createTripScheduleUpdate,
);
adminRouter.delete(
  "/trips/:id/schedule/updates/:updateId",
  adminController.deleteTripScheduleUpdate,
);

// Schedule Templates
adminRouter.get("/schedule-templates", adminController.getScheduleTemplates);
adminRouter.post(
  "/schedule-templates",
  validate(adminScheduleTemplateSchema),
  adminController.createScheduleTemplate,
);
adminRouter.put(
  "/schedule-templates/:id",
  validate(adminScheduleTemplateSchema),
  adminController.updateScheduleTemplate,
);
adminRouter.delete(
  "/schedule-templates/:id",
  adminController.deleteScheduleTemplate,
);

// Categories
adminRouter.get("/categories", adminController.getCategories);
adminRouter.post(
  "/categories",
  validate(adminCategorySchema),
  adminController.createCategory,
);
adminRouter.delete("/categories/:id", adminController.deleteCategory);

// Users
adminRouter.get("/users", adminController.getUsers);
adminRouter.post(
  "/users",
  validate(adminUserSchema),
  adminController.createUser,
);
adminRouter.delete("/users/:id", adminController.deleteUser);

// Partners
adminRouter.get("/partners", adminController.getPartners);
adminRouter.post(
  "/partners",
  validate(adminPartnerCreateSchema),
  adminController.createPartner,
);
adminRouter.put("/partners/:id", validate(adminPartnerUpdateSchema), adminController.updatePartner);
adminRouter.post("/users/:id/promote-partner", adminController.promoteUserToPartner);
adminRouter.post("/partners/:id/demote", adminController.demotePartner);
adminRouter.delete("/partners/:id", adminController.deletePartner);

// Rooms
adminRouter.get("/hotels/:hotelId/rooms", adminController.getRooms);
adminRouter.post(
  "/hotels/:hotelId/rooms",
  validate(adminRoomSchema),
  adminController.createRoom,
);
adminRouter.put(
  "/hotels/:hotelId/rooms/:roomId",
  validate(adminRoomSchema),
  adminController.updateRoom,
);
adminRouter.delete(
  "/hotels/:hotelId/rooms/:roomId",
  adminController.deleteRoom,
);

// Documents
adminRouter.get("/documents", adminController.getDocuments);
adminRouter.post(
  "/documents",
  validate(adminDocumentSchema),
  adminController.createDocument,
);
adminRouter.put(
  "/documents/:id",
  validate(adminDocumentSchema),
  adminController.updateDocument,
);
adminRouter.delete("/documents/:id", adminController.deleteDocument);
