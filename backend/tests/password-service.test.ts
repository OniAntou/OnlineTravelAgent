import { describe, expect, it } from "vitest";
import { passwordService } from "../src/services/password.service.js";

describe("passwordService", () => {
  it("stores new passwords as bcrypt hashes", async () => {
    const hash = await passwordService.hash("password123");

    expect(hash).not.toBe("password123");
    expect(hash).toMatch(/^\$2[aby]\$/);
    expect(await passwordService.verify("password123", hash)).toBe(true);
  });

  it("still verifies legacy SHA-256 hashes for migration", async () => {
    const legacyHash =
      "ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f";

    expect(await passwordService.verify("password123", legacyHash)).toBe(true);
  });
});
