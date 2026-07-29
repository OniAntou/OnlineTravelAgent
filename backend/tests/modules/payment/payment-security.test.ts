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

  it("uses the persisted trip total instead of a caller-supplied amount", async () => {
    mocks.tripFindUnique.mockResolvedValue({
      id: "trip-1",
      userId: "owner-1",
      totalPrice: 1000,
    });

    const res = await request(app)
      .post("/api/payment/vnpay/create")
      .set("Authorization", `Bearer ${tokenFor("owner-1")}`)
      .send({ tripId: "trip-1", amount: 1 });

    expect(res.status).toBe(200);
    expect(res.body.amount).toBe(1000);
    expect(mocks.createPaymentUrl).toHaveBeenCalledWith(
      expect.objectContaining({ amount: 1000 }),
    );
  });

  it("settles an owned trip through the local cash test gateway", async () => {
    mocks.tripFindUnique.mockResolvedValue({
      id: "trip-1",
      userId: "owner-1",
      totalPrice: 1000,
      status: "PENDING",
    });
    mocks.tripUpdate.mockResolvedValue({});

    const res = await request(app)
      .post("/api/payment/test/cash/confirm")
      .set("Authorization", `Bearer ${tokenFor("owner-1")}`)
      .send({ tripId: "trip-1" });

    expect(res.status).toBe(200);
    expect(res.body.paymentStatus).toBe("SUCCESS");
    expect(mocks.tripUpdate).toHaveBeenCalledWith(expect.objectContaining({
      where: { id: "trip-1" },
      data: expect.objectContaining({
        paymentMethod: "cash_test",
        paymentStatus: "SUCCESS",
        status: "ONGOING",
      }),
    }));
  });

  it("does not expose the cash test gateway in production", async () => {
    const originalNodeEnv = process.env.NODE_ENV;
    process.env.NODE_ENV = "production";

    try {
      const res = await request(app)
        .post("/api/payment/test/cash/confirm")
        .set("Authorization", `Bearer ${tokenFor("owner-1")}`)
        .send({ tripId: "trip-1" });

      expect(res.status).toBe(404);
      expect(mocks.tripFindUnique).not.toHaveBeenCalled();
    } finally {
      process.env.NODE_ENV = originalNodeEnv;
    }
  });

  it.each([
    ["post", "/api/payment/momo/create"],
    ["get", "/api/payment/momo/return"],
    ["post", "/api/payment/momo/ipn"],
  ] as const)("does not expose the removed MoMo endpoint %s %s", async (method, path) => {
    const res = await request(app)[method](path);

    expect(res.status).toBe(404);
    expect(mocks.tripUpdate).not.toHaveBeenCalled();
  });

  it("does not reactivate an Admin-cancelled booking after verified payment", async () => {
    mocks.tripFindUnique.mockResolvedValue({
      id: "trip-1",
      userId: "owner-1",
      totalPrice: 1000,
      paymentTxnRef: "trip-1-123",
      status: "CANCELLED",
    });
    mocks.verifyReturnUrl.mockReturnValue({
      isValid: true,
      txnRef: "trip-1-123",
      responseCode: "00",
      transactionNo: "txn-1",
      amount: 1000,
    });
    mocks.tripUpdate.mockResolvedValue({});

    const res = await request(app).get("/api/payment/vnpay/return");

    expect(res.status).toBe(200);
    expect(mocks.tripUpdate).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({ paymentStatus: "SUCCESS" }),
      }),
    );
    expect(mocks.tripUpdate.mock.calls[0]?.[0]?.data).not.toHaveProperty("status");
    expect(mocks.tripUpdate.mock.calls[0]?.[0]?.data).not.toHaveProperty("isUpcoming");
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
