import { Router } from "express";
import { paymentController } from "./payment.controller.js";
import { clientAuth } from "../../core/middleware/auth.js";

export const paymentRouter = Router();

paymentRouter.post("/test/cash/confirm", clientAuth, paymentController.confirmCashTestPayment);
paymentRouter.post("/vnpay/create", clientAuth, paymentController.createVnpayPayment);
paymentRouter.get("/vnpay/return", paymentController.vnpayReturn);
paymentRouter.post("/vnpay/ipn", paymentController.vnpayIpn);
paymentRouter.get("/vnpay/status/:tripId", clientAuth, paymentController.checkPaymentStatus);
