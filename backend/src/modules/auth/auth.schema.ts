import { z } from "zod";

export const loginSchema = z.object({
  email: z.string().email("email is required"),
  password: z.string().min(1, "password is required"),
});

export const registerSchema = z.object({
  name: z.string().min(1, "name is required"),
  email: z.string().email("email is required"),
  password: z.string().min(6, "password must be at least 6 characters"),
});

export const refreshSchema = z.object({
  refreshToken: z.string().min(1, "refreshToken is required"),
});

export const logoutSchema = z.object({
  refreshToken: z.string().min(1).optional(),
});
