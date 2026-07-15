import jwt from "jsonwebtoken";
import request from "supertest";
import { beforeEach, describe, expect, it, vi } from "vitest";

const mocks = vi.hoisted(() => ({
  tripFindUnique: vi.fn(),
  tripUpdate: vi.fn(),
  createPaymentUrl: vi.fn(),
  verifyReturnUrl: vi.fn(),
  updateTripPaymentStatus: vi.fn(),
  getTripPaymentStatus: vi.fn(),
}));

vi.mock("../../../src/infrastructure/database/prisma.js", () => ({
  default: {
    trip: {
      findUnique: mocks.tripFindUnique,
      update: mocks.tripUpdate,
    },
  },
}));

vi.mock("../../../src/modules/payment/vnpay.service.js", () => ({
  vnpayService: {
    createPaymentUrl: mocks.createPaymentUrl,
    verifyReturnUrl: mocks.verifyReturnUrl,
    updateTripPaymentStatus: mocks.updateTripPaymentStatus,
    getTripPaymentStatus: mocks.getTripPaymentStatus,
  },
}));

import { app } from "../../../src/app.js";

import { env } from "../../../src/core/config/env.js";

const tokenFor = (userId: string) =>
  jwt.sign({ userId, role: "USER" }, env.jwtSecret);

describe("payment security", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mocks.createPaymentUrl.mockReturnValue({
      paymentUrl: "https://sandbox.vnpay.test/pay",
      txnRef: "trip-1-123",
    });
    mocks.updateTripPaymentStatus.mockResolvedValue({});
  });

  it("rejects creating VNPAY payment for another user's trip", async () => {
    mocks.tripFindUnique.mockResolvedValue({
      id: "trip-1",
      userId: "owner-1",
      totalPrice: 1000,
    });

    const res = await request(app)
      .post("/api/payment/vnpay/create")
      .set("Authorization", `Bearer ${tokenFor("other-1")}`)
      .send({ tripId: "trip-1", amount: 1000 });

    expect(res.status).toBe(403);
    expect(mocks.createPaymentUrl).not.toHaveBeenCalled();
  });

  it("rejects creating VNPAY payment with a tampered amount", async () => {
    mocks.tripFindUnique.mockResolvedValue({
      id: "trip-1",
      userId: "owner-1",
      totalPrice: 1000,
    });

    const res = await request(app)
      .post("/api/payment/vnpay/create")
      .set("Authorization", `Bearer ${tokenFor("owner-1")}`)
      .send({ tripId: "trip-1", amount: 1 });

    expect(res.status).toBe(400);
    expect(mocks.createPaymentUrl).not.toHaveBeenCalled();
  });

  it("does not mark MoMo return paid without a valid signature", async () => {
    const res = await request(app)
      .get("/api/payment/momo/return")
      .query({
        resultCode: "0",
        orderId: "trip-1-123",
        extraData: Buffer.from("trip-1").toString("base64"),
      });

    expect(res.status).toBe(400);
    expect(mocks.tripUpdate).not.toHaveBeenCalled();
  });

  it("does not expose payment status to a different user", async () => {
    mocks.tripFindUnique.mockResolvedValue({
      id: "trip-1",
      userId: "owner-1",
      paymentStatus: "paid",
      paymentMethod: "vnpay",
      paymentTxnRef: "txn-ref",
      paymentTxnNumber: "txn-no",
      status: "Da xac nhan",
    });

    const res = await request(app)
      .get("/api/payment/vnpay/status/trip-1")
      .set("Authorization", `Bearer ${tokenFor("other-1")}`);

    expect(res.status).toBe(403);
  });
});
