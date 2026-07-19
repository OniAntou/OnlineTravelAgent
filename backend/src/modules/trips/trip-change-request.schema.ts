import { z } from "zod";

export const tripChangeRequestTypeSchema = z.enum(["RESCHEDULE", "REFUND"]);
export const tripChangeRequestStatusSchema = z.enum([
  "PENDING",
  "APPROVED",
  "REJECTED",
]);

function parseTripDate(value: string): Date | null {
  const normalized = value.trim();
  const vietnameseDate = /^(\d{1,2})\/(\d{1,2})\/(\d{4})$/.exec(normalized);
  const isoDate = /^(\d{4})-(\d{1,2})-(\d{1,2})$/.exec(normalized);

  const parts = vietnameseDate
    ? {
        day: Number(vietnameseDate[1]),
        month: Number(vietnameseDate[2]),
        year: Number(vietnameseDate[3]),
      }
    : isoDate
      ? {
          day: Number(isoDate[3]),
          month: Number(isoDate[2]),
          year: Number(isoDate[1]),
        }
      : null;

  if (!parts) return null;

  const date = new Date(Date.UTC(parts.year, parts.month - 1, parts.day));
  if (
    date.getUTCFullYear() !== parts.year ||
    date.getUTCMonth() !== parts.month - 1 ||
    date.getUTCDate() !== parts.day
  ) {
    return null;
  }

  return date;
}

export function isFutureTripDate(value: string): boolean {
  const rawParts = value.split(/\s+-\s+/);
  if (rawParts.length === 0 || rawParts.length > 2) return false;

  const parts: Date[] = [];
  for (const rawPart of rawParts) {
    const parsed = parseTripDate(rawPart);
    if (!parsed) return false;
    parts.push(parsed);
  }

  if (parts.length === 2 && parts[1].getTime() <= parts[0].getTime()) {
    return false;
  }

  const now = new Date();
  const today = Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate());
  return parts[0].getTime() > today;
}

export const createTripChangeRequestSchema = z
  .object({
    type: tripChangeRequestTypeSchema,
    reason: z
      .string()
      .trim()
      .min(5, "reason must be at least 5 characters")
      .max(500, "reason must not exceed 500 characters"),
    requestedDate: z.string().trim().min(1).optional(),
  })
  .superRefine((value, ctx) => {
    if (value.type === "RESCHEDULE") {
      if (!value.requestedDate || !isFutureTripDate(value.requestedDate)) {
        ctx.addIssue({
          code: "custom",
          path: ["requestedDate"],
          message: "requestedDate must be a valid future date",
        });
      }
      return;
    }

    if (value.requestedDate) {
      ctx.addIssue({
        code: "custom",
        path: ["requestedDate"],
        message: "requestedDate is only allowed for reschedules",
      });
    }
  });

export const reviewTripChangeRequestSchema = z.object({
  decision: z.enum(["APPROVED", "REJECTED"]),
  refundAmount: z.coerce.number().finite().nonnegative().optional(),
  adminNote: z.string().trim().max(500, "adminNote must not exceed 500 characters").optional(),
});

export const tripChangeRequestQuerySchema = z.object({
  status: tripChangeRequestStatusSchema.optional(),
});

export type CreateTripChangeRequestInput = z.infer<
  typeof createTripChangeRequestSchema
>;
export type ReviewTripChangeRequestInput = z.infer<
  typeof reviewTripChangeRequestSchema
>;
