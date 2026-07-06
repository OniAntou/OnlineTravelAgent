import { Router } from "express";
import rateLimit from "express-rate-limit";
import { clientRouter } from "./client.routes.js";
import { adminRouter } from "./admin.routes.js";
import { authRouter } from "./auth.routes.js";
import { partnerRouter } from "./partner.routes.js";
import { paymentRouter } from "./payment.routes.js";
import { adminAuth, partnerAuth } from "../middlewares/auth.js";
import { invalidateBootstrapCacheOnMutation } from "../config/cache.js";

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

routes.use("/", generalLimiter, invalidateBootstrapCacheOnMutation, clientRouter);
routes.use("/payment", paymentRouter);
routes.use("/admin", adminAuth, adminRouter);
routes.use("/partner", partnerAuth, partnerRouter);
routes.use("/auth", authLimiter, authRouter);
