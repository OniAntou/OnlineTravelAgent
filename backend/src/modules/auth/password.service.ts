import bcrypt from "bcryptjs";
import crypto from "crypto";

const BCRYPT_ROUNDS = 10;

function isBcryptHash(value: string): boolean {
  return value.startsWith("$2a$") || value.startsWith("$2b$") || value.startsWith("$2y$");
}

function sha256(value: string): string {
  return crypto.createHash("sha256").update(value).digest("hex");
}

export const passwordService = {
  async hash(password: string): Promise<string> {
    return bcrypt.hash(password, BCRYPT_ROUNDS);
  },

  async verify(password: string, storedHash: string): Promise<boolean> {
    if (isBcryptHash(storedHash)) {
      return bcrypt.compare(password, storedHash);
    }

    return sha256(password) === storedHash;
  },

  shouldMigrate(storedHash: string): boolean {
    return !isBcryptHash(storedHash);
  },
};
