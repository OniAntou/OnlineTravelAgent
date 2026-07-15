import crypto from "crypto";
import prisma from "../config/prisma.js";
import { PaymentStatus } from "@prisma/client";
import { memoryDb } from "../store/memory-db.js";

const VNP_URL = process.env.VNP_URL ?? "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html";
const VNP_RETURN_URL = process.env.VNP_RETURN_URL ?? "http://localhost:3000/api/payment/vnpay/return";
const VNP_API_URL = process.env.VNP_API_URL ?? "https://sandbox.vnpayment.vn/merchant_webapi/api/transaction";

function readVnpayCredentials(): { tmnCode: string; hashSecret: string } | null {
  const tmnCode = process.env.VNP_TMN_CODE?.trim();
  const hashSecret = process.env.VNP_HASH_SECRET?.trim();
  if (!tmnCode || !hashSecret) return null;
  return { tmnCode, hashSecret };
}

function sortObject(obj: Record<string, string>): Record<string, string> {
  const sorted: Record<string, string> = {};
  Object.keys(obj).sort().forEach((key) => {
    sorted[key] = obj[key];
  });
  return sorted;
}

function hmacSHA512(secret: string, data: string): string {
  return crypto.createHmac("sha512", secret).update(data).digest("hex");
}

export const vnpayService = {
  createPaymentUrl(params: {
    tripId: string;
    amount: number;
    orderInfo: string;
    ipAddr: string;
    locale?: string;
  }): { paymentUrl: string; txnRef: string } {
    const credentials = readVnpayCredentials();
    if (!credentials) {
      throw new Error("VNPAY is not configured");
    }

    const formatVNTime = (date: Date) => {
      const vnTime = new Date(date.getTime() + 7 * 60 * 60 * 1000);
      return vnTime.toISOString().replace(/[-:.TZ]/g, "").slice(0, 14);
    };

    const txnRef = `${params.tripId}-${Date.now()}`;
    const createDate = formatVNTime(new Date());
    const expireDate = formatVNTime(new Date(Date.now() + 15 * 60 * 1000));

    const vnpParams: Record<string, string> = {
      vnp_Version: "2.1.0",
      vnp_Command: "pay",
      vnp_TmnCode: credentials.tmnCode,
      vnp_Amount: String(Math.round(params.amount * 100)),
      vnp_CreateDate: createDate,
      vnp_CurrCode: "VND",
      vnp_IpAddr: params.ipAddr,
      vnp_Locale: params.locale ?? "vn",
      vnp_OrderInfo: params.orderInfo,
      vnp_OrderType: "other",
      vnp_ReturnUrl: VNP_RETURN_URL,
      vnp_TxnRef: txnRef,
      vnp_ExpireDate: expireDate,
    };

    const sortedParams = sortObject(vnpParams);
    const signData = new URLSearchParams(sortedParams).toString();
    const secureHash = hmacSHA512(credentials.hashSecret, signData);
    sortedParams["vnp_SecureHash"] = secureHash;

    const paymentUrl = `${VNP_URL}?${new URLSearchParams(sortedParams).toString()}`;
    return { paymentUrl, txnRef };
  },

  verifyReturnUrl(query: Record<string, string>): {
    isValid: boolean;
    txnRef: string;
    responseCode: string;
    transactionNo: string;
    amount: number;
  } {
    const credentials = readVnpayCredentials();
    if (!credentials) {
      return {
        isValid: false,
        txnRef: query["vnp_TxnRef"] ?? "",
        responseCode: query["vnp_ResponseCode"] ?? "99",
        transactionNo: query["vnp_TransactionNo"] ?? "",
        amount: Number.parseInt(query["vnp_Amount"] ?? "0", 10) / 100,
      };
    }

    const secureHash = query["vnp_SecureHash"];
    const params = { ...query };
    delete params["vnp_SecureHash"];
    delete params["vnp_SecureHashType"];

    const sortedParams = sortObject(params);
    const signData = new URLSearchParams(sortedParams).toString();
    const computedHash = hmacSHA512(credentials.hashSecret, signData);

    return {
      isValid: computedHash === secureHash,
      txnRef: query["vnp_TxnRef"] ?? "",
      responseCode: query["vnp_ResponseCode"] ?? "99",
      transactionNo: query["vnp_TransactionNo"] ?? "",
      amount: Number.parseInt(query["vnp_Amount"] ?? "0", 10) / 100,
    };
  },

  async queryTransaction(txnRef: string): Promise<{
    isValid: boolean;
    responseCode: string;
    transactionNo: string;
    amount: number;
    payDate: string;
    transactionType: string;
    bankCode: string;
  } | null> {
    const credentials = readVnpayCredentials();
    if (!credentials) return null;

    const vnpRequestId = `${Date.now()}`;
    const vnpVersion = "2.1.0";
    const vnpCommand = "querydr";
    const vnpTmnCode = credentials.tmnCode;
    const vnpTxnRef = txnRef;
    const vnpOrderInfo = "Kiem tra giao dich";
    const vnpTransDate = new Date().toISOString().replace(/[-:.TZ]/g, "").slice(0, 14);
    const vnpCreateDate = new Date().toISOString().replace(/[-:.TZ]/g, "").slice(0, 14);
    const vnpCreateBy = "online_travel_agent";
    const vnpIpAddr = "127.0.0.1";

    const data = `${vnpRequestId}|${vnpVersion}|${vnpCommand}|${vnpTmnCode}|${vnpTxnRef}|${vnpTransDate}|${vnpCreateDate}|${vnpCreateBy}|${vnpOrderInfo}|${vnpIpAddr}`;
    const secureHash = hmacSHA512(credentials.hashSecret, data);

    const body = {
      vnp_RequestId: vnpRequestId,
      vnp_Version: vnpVersion,
      vnp_Command: vnpCommand,
      vnp_TmnCode: vnpTmnCode,
      vnp_TxnRef: vnpTxnRef,
      vnp_OrderInfo: vnpOrderInfo,
      vnp_TransDate: vnpTransDate,
      vnp_CreateDate: vnpCreateDate,
      vnp_CreateBy: vnpCreateBy,
      vnp_IpAddr: vnpIpAddr,
      vnp_SecureHash: secureHash,
    };

    try {
      const response = await fetch(VNP_API_URL, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(body),
      });
      const result = await response.json() as Record<string, string>;

      return {
        isValid: result["vnp_ResponseCode"] === "00",
        responseCode: result["vnp_ResponseCode"] ?? "99",
        transactionNo: result["vnp_TransactionNo"] ?? "",
        amount: Number.parseInt(result["vnp_Amount"] ?? "0", 10) / 100,
        payDate: result["vnp_PayDate"] ?? "",
        transactionType: result["vnp_TransactionType"] ?? "",
        bankCode: result["vnp_BankCode"] ?? "",
      };
    } catch {
      return null;
    }
  },

  async updateTripPaymentStatus(tripId: string, status: PaymentStatus, txnRef?: string, txnNumber?: string) {
    try {
      return await prisma.trip.update({
        where: { id: tripId },
        data: {
          paymentStatus: status,
          paymentMethod: "vnpay",
          ...(txnRef ? { paymentTxnRef: txnRef } : {}),
          ...(txnNumber ? { paymentTxnNumber: txnNumber } : {}),
        },
      });
    } catch {
      memoryDb.updateTrip(tripId, {
        paymentStatus: status as any,
        paymentMethod: "vnpay",
        paymentTxnRef: txnRef || null,
        paymentTxnNumber: txnNumber || null,
      });
    }
  },

  async getTripPaymentStatus(tripId: string) {
    try {
      const trip = await prisma.trip.findUnique({
        where: { id: tripId },
        select: { paymentStatus: true, paymentMethod: true, paymentTxnRef: true, paymentTxnNumber: true, status: true },
      });
      return trip;
    } catch {
      const trip = memoryDb.findTripById(tripId);
      if (!trip) return null;
      return {
        paymentStatus: trip.paymentStatus,
        paymentMethod: trip.paymentMethod,
        paymentTxnRef: trip.paymentTxnRef,
        paymentTxnNumber: trip.paymentTxnNumber,
        status: trip.status,
      };
    }
  },
};
