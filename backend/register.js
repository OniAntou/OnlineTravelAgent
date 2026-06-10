import crypto from "crypto";
import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

const hashPassword = (password) =>
  crypto.createHash("sha256").update(password, "utf8").digest("hex");

export const registerHandler = async (req, res) => {
  try {
    const { name, email, password } = req.body ?? {};

    if (!name || !email || !password) {
      return res.status(400).json({ message: "Name, email and password are required." });
    }

    const existingUser = await prisma.users.findUnique({
      where: { email },
    });

    if (existingUser) {
      return res.status(409).json({ message: "Email already registered." });
    }

    const hashedPassword = hashPassword(password);

    const user = await prisma.users.create({
      data: {
        id: crypto.randomUUID(),
        name,
        email,
        password: hashedPassword,
      },
    });

    const { password: _, ...safeUser } = user;
    return res.status(201).json({ user: safeUser });
  } catch (error) {
    console.error("[register]", error);
    return res.status(500).json({ message: "Failed to register user." });
  }
};
