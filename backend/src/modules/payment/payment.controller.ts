import { Request, Response } from "express";
import crypto from "crypto";
import prisma from "../../infrastructure/database/prisma.js";
import { vnpayService } from "./vnpay.service.js";
import { asyncHandler } from "../../core/utils/asyncHandler.js";
import { PaymentStatus, Prisma, TripStatus } from "@prisma/client";
import { memoryDb } from "../../infrastructure/fallback/memory-db.js";
import { invalidateBootstrapUserCache } from "../../core/config/cache.js";

const MOMO_PARTNER_CODE = process.env.MOMO_PARTNER_CODE ?? "MOMO";
const MOMO_ACCESS_KEY = process.env.MOMO_ACCESS_KEY ?? "";
const MOMO_SECRET_KEY = process.env.MOMO_SECRET_KEY ?? "";
const MOMO_URL =
  process.env.MOMO_URL ?? "https://test-payment.momo.vn/v2/gateway/api/create";
const PAYMENT_AMOUNT_TOLERANCE = 1;

type PaymentTrip = {
  id: string;
  userId: string | null;
  totalPrice: Prisma.Decimal | number | null;
  paymentTxnRef?: string | null;
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
      select: { id: true, userId: true, totalPrice: true, paymentTxnRef: true },
    });
  } catch {
    const trip = memoryDb.findTripById(tripId);
    if (!trip) return null;
    return { id: trip.id, userId: trip.userId || null, totalPrice: trip.totalPrice || null, paymentTxnRef: trip.paymentTxnRef || null };
  }
}

async function validateClientPaymentRequest(
  userId: string | undefined,
  tripId: string,
  amount: number,
): Promise<{ status?: number; message?: string; trip?: PaymentTrip }> {
  const trip = await loadPaymentTrip(tripId);
  if (!trip) return { status: 404, message: "Trip not found" };
  if (!userId || trip.userId !== userId) {
    return {
      status: 403,
      message: "Forbidden - Trip does not belong to this user",
    };
  }
  if (!amountMatches(trip.totalPrice, amount)) {
    return { status: 400, message: "Payment amount does not match trip total" };
  }
  return { trip };
}

function tripIdFromTxnRef(txnRef: string): string {
  const parts = txnRef.split("-");
  parts.pop();
  return parts.join("-");
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
      await prisma.trip.update({ where: { id: tripId }, data: { ...updateData, paymentStatus: PaymentStatus.SUCCESS, status: TripStatus.ONGOING, isUpcoming: true } });
    } catch {
      memoryDb.updateTrip(tripId, { ...updateData, paymentStatus: "SUCCESS" as const, status: "ONGOING" as const, isUpcoming: true });
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

function buildMomoRawSignature(query: Record<string, string>): string {
  const fields = [
    "accessKey",
    "amount",
    "extraData",
    "message",
    "orderId",
    "orderInfo",
    "orderType",
    "partnerCode",
    "payType",
    "requestId",
    "responseTime",
    "resultCode",
    "transId",
  ];

  return fields
    .map(
      (field) =>
        `${field}=${field === "accessKey" ? MOMO_ACCESS_KEY : (query[field] ?? "")}`,
    )
    .join("&");
}

function verifyMomoSignature(query: Record<string, string>): boolean {
  if (!MOMO_SECRET_KEY || !MOMO_ACCESS_KEY || !query.signature) return false;
  const expected = crypto
    .createHmac("sha256", MOMO_SECRET_KEY)
    .update(buildMomoRawSignature(query))
    .digest("hex");
  const left = Buffer.from(expected);
  const right = Buffer.from(query.signature);
  return left.length === right.length && crypto.timingSafeEqual(left, right);
}

async function markMomoResult(query: Record<string, string>): Promise<boolean> {
  if (!verifyMomoSignature(query)) return false;

  const tripId = Buffer.from(query["extraData"] ?? "", "base64").toString(
    "utf-8",
  );
  const amount = parsePositiveAmount(query["amount"]);
  const orderId = query["orderId"] ?? "";
  if (!tripId || !amount || !orderId) return false;

  const trip = await loadPaymentTrip(tripId);
  if (
    !trip ||
    trip.paymentTxnRef !== orderId ||
    !amountMatches(trip.totalPrice, amount)
  ) {
    return false;
  }

  const updateData = {
    paymentMethod: "momo" as const,
    paymentTxnRef: orderId,
    paymentTxnNumber: query["transId"] ?? null,
  };

  if (query["resultCode"] === "0") {
    try {
      await prisma.trip.update({ where: { id: tripId }, data: { ...updateData, paymentStatus: PaymentStatus.SUCCESS, status: TripStatus.ONGOING, isUpcoming: true } });
    } catch {
      memoryDb.updateTrip(tripId, { ...updateData, paymentStatus: "SUCCESS" as const, status: "ONGOING" as const, isUpcoming: true });
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
  createVnpayPayment: asyncHandler(async (req: Request, res: Response) => {
    const { tripId, amount, orderInfo } = req.body;
    const parsedAmount = parsePositiveAmount(amount);
    if (!tripId || !parsedAmount) {
      res.status(400).json({ message: "tripId and amount are required" });
      return;
    }

    const validation = await validateClientPaymentRequest(
      req.userId,
      tripId,
      parsedAmount,
    );
    if (!validation.trip) {
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
        amount: parsedAmount,
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
      amount: parsedAmount,
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

  createMomoPayment: asyncHandler(async (req: Request, res: Response) => {
    const { tripId, amount, orderInfo } = req.body;
    const parsedAmount = parsePositiveAmount(amount);
    if (!tripId || !parsedAmount) {
      res.status(400).json({ message: "tripId and amount are required" });
      return;
    }

    const validation = await validateClientPaymentRequest(
      req.userId,
      tripId,
      parsedAmount,
    );
    if (!validation.trip) {
      res
        .status(validation.status ?? 400)
        .json({ message: validation.message });
      return;
    }

    if (!MOMO_ACCESS_KEY || !MOMO_SECRET_KEY) {
      res.status(501).json({
        message: "MoMo payment is not configured. Please contact support.",
        note: "Vui long lien he quan tri vien de cau hinh thanh toan MoMo.",
      });
      return;
    }

    const orderId = `${tripId}-${Date.now()}`;
    const requestId = orderId;
    const orderInfoStr = orderInfo ?? `Thanh toan Momo cho don hang ${tripId}`;
    const redirectUrl = `${req.protocol}://${req.get("host")}/api/payment/momo/return`;
    const ipnUrl = `${req.protocol}://${req.get("host")}/api/payment/momo/ipn`;
    const extraData = Buffer.from(tripId).toString("base64");

    const rawSignature = `accessKey=${MOMO_ACCESS_KEY}&amount=${parsedAmount}&extraData=${extraData}&ipnUrl=${ipnUrl}&orderId=${orderId}&orderInfo=${orderInfoStr}&partnerCode=${MOMO_PARTNER_CODE}&redirectUrl=${redirectUrl}&requestId=${requestId}&requestType=captureWallet`;
    const signature = crypto
      .createHmac("sha256", MOMO_SECRET_KEY)
      .update(rawSignature)
      .digest("hex");

    const requestBody = {
      partnerCode: MOMO_PARTNER_CODE,
      partnerName: "Online Travel Agent",
      storeId: "OnlineTravelAgent",
      requestId,
      amount: parsedAmount,
      orderId,
      orderInfo: orderInfoStr,
      redirectUrl,
      ipnUrl,
      lang: "vi",
      extraData,
      requestType: "captureWallet",
      signature,
    };

    try {
      const response = await fetch(MOMO_URL, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(requestBody),
      });
      const result = (await response.json()) as Record<string, string>;

      if (result.resultCode === "0" || result.payUrl) {
        try {
          await prisma.trip.update({ where: { id: tripId }, data: { paymentStatus: PaymentStatus.PENDING, paymentMethod: "momo", paymentTxnRef: orderId } });
        } catch {
          memoryDb.updateTrip(tripId, { paymentStatus: "PENDING" as any, paymentMethod: "momo", paymentTxnRef: orderId });
        }
        if (validation.trip.userId) {
          invalidateBootstrapUserCache(validation.trip.userId);
        }
        res.json({
          payUrl: result.payUrl,
          orderId,
          tripId,
          amount: parsedAmount,
          deeplink: result.deeplink,
          qrCodeUrl: result.qrCodeUrl,
        });
      } else {
        res
          .status(400)
          .json({ message: result.message ?? "MoMo payment creation failed" });
      }
    } catch {
      res.status(500).json({ message: "Failed to create MoMo payment" });
    }
  }),

  momoReturn: asyncHandler(async (req: Request, res: Response) => {
    const query = req.query as Record<string, string>;
    const accepted = await markMomoResult(query);
    if (!accepted) {
      res.status(400).send("Invalid MoMo signature");
      return;
    }
    res.send(
      paymentResultHtml(
        "MoMo",
        query["resultCode"] === "0",
        query["orderId"] ?? "",
      ),
    );
  }),

  momoIpn: asyncHandler(async (req: Request, res: Response) => {
    const query = req.body as Record<string, string>;
    if (await markMomoResult(query)) {
      res.status(200).json({ resultCode: 0, message: "Confirm Success" });
      return;
    }
    res.status(400).json({ resultCode: 97, message: "Invalid Signature" });
  }),
};
