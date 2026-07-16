import { Router } from "express";
import rateLimit from "express-rate-limit";
import { clientRouter } from "./client/client.routes.js";
import { adminRouter } from "./admin/admin.routes.js";
import { authRouter } from "./auth/auth.routes.js";
import { partnerRouter } from "./partner/partner.routes.js";
import { paymentRouter } from "./payment/payment.routes.js";
import { adminAuth, partnerAuth } from "../core/middleware/auth.js";

export const routes = Router();

// Strict rate limit for auth endpoints (login/register)
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 20,
  standardHeaders: true,
  legacyHeaders: false,
  message: { message: "Too many login attempts, please try again later" },
});

// General API rate limit (generous for normal usage)
const generalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 500,
  standardHeaders: true,
  legacyHeaders: false,
  message: { message: "Too many requests, please try again later" },
});

routes.use("/", generalLimiter, clientRouter);
routes.use("/payment", paymentRouter);
routes.use("/admin", adminAuth, adminRouter);
routes.use("/partner", partnerAuth, partnerRouter);
routes.use("/auth", authLimiter, authRouter);
