import { Request, Response } from "express";
import prisma from "../../infrastructure/database/prisma.js";
import { vnpayService } from "./vnpay.service.js";
import { asyncHandler } from "../../core/utils/asyncHandler.js";
import { PaymentStatus, Prisma, TripStatus } from "@prisma/client";
import { memoryDb } from "../../infrastructure/fallback/memory-db.js";
import { invalidateBootstrapUserCache } from "../../core/config/cache.js";

const PAYMENT_AMOUNT_TOLERANCE = 1;

type PaymentTrip = {
  id: string;
  userId: string | null;
  totalPrice: Prisma.Decimal | number | null;
  paymentTxnRef?: string | null;
  status: TripStatus;
};

type ConfirmedPaymentFields = {
  paymentMethod: "vnpay" | "cash_test";
  paymentTxnRef: string;
  paymentTxnNumber: string | null;
};

function parsePositiveAmount(value: unknown): number | null {
  const amount = Number(value);
  return Number.isFinite(amount) && amount > 0 ? amount : null;
}

function amountMatches(
  expected: Prisma.Decimal | number | null | undefined,
  actual: number,
): boolean {
  if (expected === null || expected === undefined) return true;
  return Math.abs(Number(expected) - actual) <= PAYMENT_AMOUNT_TOLERANCE;
}

async function loadPaymentTrip(tripId: string): Promise<PaymentTrip | null> {
  try {
    return await prisma.trip.findUnique({
      where: { id: tripId },
      select: { id: true, userId: true, totalPrice: true, paymentTxnRef: true, status: true },
    });
  } catch {
    const trip = memoryDb.findTripById(tripId);
    if (!trip) return null;
    return {
      id: trip.id,
      userId: trip.userId || null,
      totalPrice: trip.totalPrice || null,
      paymentTxnRef: trip.paymentTxnRef || null,
      status: trip.status as TripStatus,
    };
  }
}

async function validateClientPaymentRequest(
  userId: string | undefined,
  tripId: string,
): Promise<{
  status?: number;
  message?: string;
  trip?: PaymentTrip;
  amount?: number;
}> {
  const trip = await loadPaymentTrip(tripId);
  if (!trip) return { status: 404, message: "Trip not found" };
  if (!userId || trip.userId !== userId) {
    return {
      status: 403,
      message: "Forbidden - Trip does not belong to this user",
    };
  }
  const amount = parsePositiveAmount(trip.totalPrice);
  if (!amount) {
    return { status: 409, message: "Trip total is unavailable for payment" };
  }
  return { trip, amount };
}

function tripIdFromTxnRef(txnRef: string): string {
  const parts = txnRef.split("-");
  parts.pop();
  return parts.join("-");
}

function testPaymentsEnabled() {
  return process.env.NODE_ENV !== "production" && process.env.ALLOW_TEST_PAYMENTS !== "false";
}

function confirmedPaymentTripUpdate(
  trip: PaymentTrip,
  payment: ConfirmedPaymentFields,
) {
  if (trip.status !== TripStatus.PENDING) {
    return { ...payment, paymentStatus: PaymentStatus.SUCCESS };
  }

  return {
    ...payment,
    paymentStatus: PaymentStatus.SUCCESS,
    status: TripStatus.ONGOING,
    isUpcoming: true,
  };
}

async function markVnpayResult(result: {
  isValid: boolean;
  txnRef: string;
  responseCode: string;
  transactionNo: string;
  amount: number;
}): Promise<boolean> {
  const tripId = tripIdFromTxnRef(result.txnRef);
  if (!result.isValid || !tripId) return false;

  const trip = await loadPaymentTrip(tripId);
  if (
    !trip ||
    trip.paymentTxnRef !== result.txnRef ||
    !amountMatches(trip.totalPrice, result.amount)
  ) {
    return false;
  }

  const updateData = {
    paymentMethod: "vnpay" as const,
    paymentTxnRef: result.txnRef,
    paymentTxnNumber: result.transactionNo,
  };

  if (result.responseCode === "00") {
    try {
      await prisma.trip.update({
        where: { id: tripId },
        data: confirmedPaymentTripUpdate(trip, updateData),
      });
    } catch {
      memoryDb.updateTrip(tripId, confirmedPaymentTripUpdate(trip, updateData));
    }
  } else {
    try {
      await prisma.trip.update({ where: { id: tripId }, data: { ...updateData, paymentStatus: PaymentStatus.FAILED } });
    } catch {
      memoryDb.updateTrip(tripId, { ...updateData, paymentStatus: "FAILED" as const });
    }
  }
  if (trip.userId) invalidateBootstrapUserCache(trip.userId);
  return true;
}

function paymentResultHtml(
  provider: string,
  success: boolean,
  reference: string,
): string {
  return `
    <!DOCTYPE html>
    <html lang="vi">
    <head><meta charset="UTF-8"><title>Ket qua thanh toan</title>
    <style>
      body { font-family: sans-serif; display: flex; justify-content: center; align-items: center; min-height: 100vh; margin: 0; background: #f5f5f5; }
      .card { background: white; padding: 40px; border-radius: 16px; box-shadow: 0 4px 20px rgba(0,0,0,0.1); text-align: center; max-width: 400px; }
      .icon { font-size: 64px; margin-bottom: 16px; }
      .success { color: #07D95A; }
      .fail { color: #E53E3E; }
      h2 { margin: 8px 0; }
      p { color: #666; margin: 8px 0 24px; }
      .btn { background: #176FF2; color: white; border: none; padding: 12px 32px; border-radius: 12px; font-size: 16px; cursor: pointer; text-decoration: none; display: inline-block; }
    </style>
    </head>
    <body>
      <div class="card">
        <div class="icon ${success ? "success" : "fail"}">${success ? "OK" : "X"}</div>
        <h2>${success ? `Thanh toan ${provider} thanh cong` : `Thanh toan ${provider} that bai`}</h2>
        <p>${success ? "Cam on ban da thanh toan. Vui long quay lai ung dung de kiem tra chuyen di." : "Thanh toan khong hop le hoac da that bai. Vui long thu lai."}</p>
        <p style="font-size:12px;color:#999;">Ma tham chieu: ${reference}</p>
        <p class="btn" role="status">Quay lai ung dung OTA</p>
      </div>
    </body>
    </html>
  `;
}

export const paymentController = {
  confirmCashTestPayment: asyncHandler(async (req: Request, res: Response) => {
    if (!testPaymentsEnabled()) {
      res.status(404).json({ message: "Test payment gateway is disabled" });
      return;
    }

    const { tripId } = req.body;
    if (!tripId) {
      res.status(400).json({ message: "tripId is required" });
      return;
    }

    const validation = await validateClientPaymentRequest(req.userId, tripId);
    if (!validation.trip || !validation.amount) {
      res.status(validation.status ?? 400).json({ message: validation.message });
      return;
    }

    const updateData = confirmedPaymentTripUpdate(validation.trip, {
      paymentMethod: "cash_test",
      paymentTxnRef: `cash-test-${tripId}-${Date.now()}`,
      paymentTxnNumber: null,
    });
    try {
      await prisma.trip.update({ where: { id: tripId }, data: updateData });
    } catch {
      memoryDb.updateTrip(tripId, updateData);
    }
    if (validation.trip.userId) invalidateBootstrapUserCache(validation.trip.userId);

    res.json({
      tripId,
      amount: validation.amount,
      paymentStatus: PaymentStatus.SUCCESS,
      paymentMethod: "cash_test",
    });
  }),

  createVnpayPayment: asyncHandler(async (req: Request, res: Response) => {
    const { tripId, orderInfo } = req.body;
    if (!tripId) {
      res.status(400).json({ message: "tripId is required" });
      return;
    }

    const validation = await validateClientPaymentRequest(
      req.userId,
      tripId,
    );
    if (!validation.trip || !validation.amount) {
      res
        .status(validation.status ?? 400)
        .json({ message: validation.message });
      return;
    }

    let ipAddr = req.ip ?? req.socket.remoteAddress ?? "127.0.0.1";
    if (ipAddr === "::1" || ipAddr === "::ffff:127.0.0.1") {
      ipAddr = "127.0.0.1";
    }
    const locale = (req.body.locale as string) ?? "vn";

    let paymentUrl: string;
    let txnRef: string;
    try {
      const payment = vnpayService.createPaymentUrl({
        tripId,
        amount: validation.amount,
        orderInfo: orderInfo ?? `Thanh toan cho don hang ${tripId}`,
        ipAddr,
        locale,
      });
      paymentUrl = payment.paymentUrl;
      txnRef = payment.txnRef;
    } catch {
      res.status(501).json({ message: "VNPAY payment is not configured" });
      return;
    }

    await vnpayService.updateTripPaymentStatus(
      tripId,
      PaymentStatus.PENDING,
      txnRef,
    );
    if (validation.trip.userId) {
      invalidateBootstrapUserCache(validation.trip.userId);
    }

    res.json({
      paymentUrl,
      txnRef,
      tripId,
      amount: validation.amount,
    });
  }),

  vnpayReturn: asyncHandler(async (req: Request, res: Response) => {
    const result = vnpayService.verifyReturnUrl(
      req.query as Record<string, string>,
    );
    const accepted = await markVnpayResult(result);
    res
      .status(accepted ? 200 : 400)
      .send(
        paymentResultHtml(
          "VNPAY",
          accepted && result.responseCode === "00",
          result.txnRef,
        ),
      );
  }),

  vnpayIpn: asyncHandler(async (req: Request, res: Response) => {
    const result = vnpayService.verifyReturnUrl(
      req.query as Record<string, string>,
    );
    if (await markVnpayResult(result)) {
      res.status(200).json({ RspCode: "00", Message: "Confirm Success" });
      return;
    }
    res.status(200).json({ RspCode: "97", Message: "Invalid Signature" });
  }),

  checkPaymentStatus: asyncHandler(async (req: Request, res: Response) => {
    const tripId = req.params.tripId ? String(req.params.tripId) : "";
    if (!tripId) {
      res.status(400).json({ message: "tripId is required" });
      return;
    }

    let trip: any = null;
    try {
      trip = await prisma.trip.findUnique({
        where: { id: tripId },
        select: {
          userId: true,
          paymentStatus: true,
          paymentMethod: true,
          paymentTxnRef: true,
          paymentTxnNumber: true,
          status: true,
        },
      });
    } catch {
      const memTrip = memoryDb.findTripById(tripId);
      if (memTrip) {
        trip = {
          userId: memTrip.userId,
          paymentStatus: memTrip.paymentStatus,
          paymentMethod: memTrip.paymentMethod,
          paymentTxnRef: memTrip.paymentTxnRef,
          paymentTxnNumber: memTrip.paymentTxnNumber,
          status: memTrip.status,
        };
      }
    }

    if (!trip) {
      res.status(404).json({ message: "Trip not found" });
      return;
    }
    if (trip.userId !== req.userId) {
      res
        .status(403)
        .json({ message: "Forbidden - Trip does not belong to this user" });
      return;
    }

    const { userId: _, ...status } = trip;
    res.json(status);
  }),

};
