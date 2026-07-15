import { Router } from "express";
import { partnerController } from "../controllers/partner.controller.js";
import { upload } from "../core/middleware/upload.js";
import { validate } from "../core/middleware/validate.js";
import { adminHotelSchema, adminRoomSchema, adminTourSchema } from "../schemas/admin.schema.js";

export const partnerRouter = Router();

partnerRouter.post("/upload", upload.single("file"), (req, res) => {
  if (!req.file) {
    return res.status(400).json({ error: "No file uploaded" });
  }
  res.json({ url: `/uploads/${req.file.filename}` });
});

partnerRouter.get("/stats", partnerController.getStats);
partnerRouter.get("/hotels", partnerController.getHotels);
partnerRouter.post("/hotels", validate(adminHotelSchema), partnerController.createHotel);
partnerRouter.put("/hotels/:id", validate(adminHotelSchema), partnerController.updateHotel);
partnerRouter.delete("/hotels/:id", partnerController.deleteHotel);

partnerRouter.get("/tours", partnerController.getTours);
partnerRouter.post("/tours", validate(adminTourSchema), partnerController.createTour);
partnerRouter.put("/tours/:id", validate(adminTourSchema), partnerController.updateTour);
partnerRouter.delete("/tours/:id", partnerController.deleteTour);

partnerRouter.get("/hotels/:hotelId/rooms", partnerController.getRooms);
partnerRouter.post("/hotels/:hotelId/rooms", validate(adminRoomSchema), partnerController.createRoom);
partnerRouter.put("/hotels/:hotelId/rooms/:roomId", validate(adminRoomSchema), partnerController.updateRoom);
partnerRouter.delete("/hotels/:hotelId/rooms/:roomId", partnerController.deleteRoom);
