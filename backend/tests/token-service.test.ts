import crypto from "crypto";
import { beforeEach, describe, expect, it, vi } from "vitest";

const mocks = vi.hoisted(() => ({
  refreshCreate: vi.fn(),
  refreshFindUnique: vi.fn(),
  refreshUpdate: vi.fn(),
  refreshUpdateMany: vi.fn(),
  queryRaw: vi.fn(),
}));

vi.mock("../src/config/prisma.js", () => ({
  default: {
    $queryRaw: mocks.queryRaw,
    refreshToken: {
      create: mocks.refreshCreate,
      findUnique: mocks.refreshFindUnique,
      update: mocks.refreshUpdate,
      updateMany: mocks.refreshUpdateMany,
    },
  },
}));

import { tokenService } from "../src/services/token.service.js";

describe("tokenService", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mocks.refreshCreate.mockResolvedValue({});
    mocks.refreshFindUnique.mockResolvedValue(null);
    mocks.refreshUpdate.mockResolvedValue({});
    mocks.refreshUpdateMany.mockResolvedValue({ count: 1 });
    mocks.queryRaw.mockResolvedValue([{ ok: 1 }]);
  });

  it("issues access and refresh tokens", async () => {
    const result = await tokenService.issueTokenPair({ id: "user-1", role: "USER" });

    expect(result.accessToken).toBeTruthy();
    expect(result.refreshToken).toBeTruthy();
    expect(result.expiresIn).toBe(900);
    expect(mocks.refreshCreate).toHaveBeenCalledOnce();
  });

  it("rotates refresh token and revokes the old one", async () => {
    const refreshToken = "refresh-token-value";
    const tokenHash = crypto.createHash("sha256").update(refreshToken).digest("hex");

    mocks.refreshFindUnique.mockResolvedValue({
      id: "rt-1",
      revokedAt: null,
      expiresAt: new Date(Date.now() + 60_000),
      user: { id: "user-1", role: "USER" },
    });

    const result = await tokenService.rotateRefreshToken(refreshToken);

    expect(result?.accessToken).toBeTruthy();
    expect(mocks.refreshUpdate).toHaveBeenCalledWith({
      where: { id: "rt-1" },
      data: { revokedAt: expect.any(Date) },
    });
    expect(mocks.refreshCreate).toHaveBeenCalledWith({
      data: {
        userId: "user-1",
        tokenHash: expect.not.stringMatching(tokenHash),
        expiresAt: expect.any(Date),
      },
    });
  });

  it("rejects expired refresh token", async () => {
    mocks.refreshFindUnique.mockResolvedValue({
      id: "rt-1",
      revokedAt: null,
      expiresAt: new Date(Date.now() - 60_000),
      user: { id: "user-1", role: "USER" },
    });

    const result = await tokenService.rotateRefreshToken("expired-token");
    expect(result).toBeNull();
  });
});
