import { Router } from "express";
import { authController } from "./auth.controller.js";
import { validate } from "../../core/middleware/validate.js";
import { clientAuth, optionalAuth } from "../../core/middleware/auth.js";
import { loginSchema, registerSchema, refreshSchema, logoutSchema } from "./auth.schema.js";

export const authRouter = Router();

authRouter.post("/login", validate(loginSchema), authController.login);
authRouter.post("/register", validate(registerSchema), authController.register);
authRouter.post("/refresh", validate(refreshSchema), authController.refresh);
authRouter.post("/logout", optionalAuth, validate(logoutSchema), authController.logout);
authRouter.post("/become-partner", clientAuth, authController.becomePartner);
