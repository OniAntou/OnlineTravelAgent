import { Router } from "express";
import { paymentController } from "../controllers/payment.controller.js";
import { clientAuth } from "../core/middleware/auth.js";

export const paymentRouter = Router();

paymentRouter.post("/vnpay/create", clientAuth, paymentController.createVnpayPayment);
paymentRouter.get("/vnpay/return", paymentController.vnpayReturn);
paymentRouter.post("/vnpay/ipn", paymentController.vnpayIpn);
paymentRouter.get("/vnpay/status/:tripId", clientAuth, paymentController.checkPaymentStatus);

paymentRouter.post("/momo/create", clientAuth, paymentController.createMomoPayment);
paymentRouter.get("/momo/return", paymentController.momoReturn);
paymentRouter.post("/momo/ipn", paymentController.momoIpn);
