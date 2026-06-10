import crypto from "crypto";
import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

const hashPassword = (password) =>
  crypto.createHash("sha256").update(password, "utf8").digest("hex");

export const loginHandler = async (req, res) => {
  try {
    const { email, password } = req.body ?? {};

    if (!email || !password) {
      return res.status(400).json({ message: "Email and password are required." });
    }

    const user = await prisma.users.findUnique({
      where: { email },
    });

    if (!user) {
      return res.status(401).json({ message: "Invalid email or password." });
    }

    const hashedPassword = hashPassword(password);
    if (user.password !== hashedPassword) {
      return res.status(401).json({ message: "Invalid email or password." });
    }

    const { password: _, ...safeUser } = user;
    return res.json({ user: safeUser });
  } catch (error) {
    console.error("[login]", error);
    return res.status(500).json({ message: "Failed to login." });
  }
};
