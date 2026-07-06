import { z } from "zod";

const emptyToUndefined = (value: unknown) =>
  value === undefined || value === null || value === "" ? undefined : value;

const optionalText = z.preprocess(
  emptyToUndefined,
  z.coerce.string().trim().min(1).optional(),
);
const requiredText = (field: string) => z.coerce.string().trim().min(1, `${field} is required`);
const optionalMoney = z.preprocess(
  emptyToUndefined,
  z.coerce.number().finite().nonnegative().optional(),
);

const parseDateInput = (value: string) => {
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
};

export const bookTripSchema = z.object({
  destinationId: requiredText("destinationId"),
  date: requiredText("date"),
  guests: requiredText("guests"),
  totalPrice: optionalMoney,
});

export const bookFlightSchema = z.object({
  flightId: requiredText("flightId"),
  date: requiredText("date"),
  guests: requiredText("guests"),
});

export const documentSchema = z.object({
  title: requiredText("title"),
  description: requiredText("description"),
  icon: requiredText("icon"),
  color: requiredText("color"),
});

export const bookHotelSchema = z
  .object({
    roomId: requiredText("roomId"),
    checkIn: requiredText("checkIn"),
    checkOut: requiredText("checkOut"),
    guests: requiredText("guests"),
  })
  .superRefine((value, ctx) => {
    const checkIn = parseDateInput(value.checkIn);
    const checkOut = parseDateInput(value.checkOut);

    if (!checkIn) {
      ctx.addIssue({
        code: "custom",
        path: ["checkIn"],
        message: "checkIn must be a valid date",
      });
    }

    if (!checkOut) {
      ctx.addIssue({
        code: "custom",
        path: ["checkOut"],
        message: "checkOut must be a valid date",
      });
    }

    if (!checkIn || !checkOut) return;

    if (checkOut.getTime() <= checkIn.getTime()) {
      ctx.addIssue({
        code: "custom",
        path: ["checkOut"],
        message: "checkOut must be after checkIn",
      });
    }
  });

export const bookTourSchema = z.object({
  tourId: requiredText("tourId"),
  date: requiredText("date"),
  guests: requiredText("guests"),
  totalPrice: optionalMoney,
});

export const customTourSchema = z.object({
  destination: requiredText("destination"),
  location: requiredText("location"),
  date: requiredText("date"),
  guests: requiredText("guests"),
  imagePath: requiredText("imagePath"),
  flightId: optionalText,
  hotelId: optionalText,
  flightIds: z.array(z.string().min(1)).optional(),
  hotelIds: z.array(z.string().min(1)).optional(),
  roomId: optionalText,
  totalPrice: optionalMoney,
});

export const reviewSchema = z.object({
  targetType: requiredText("targetType"),
  targetId: requiredText("targetId"),
  rating: z.coerce.number().int().min(1).max(5, "rating must be 1-5"),
  comment: z.coerce.string().trim().min(1, "comment is required").max(1000),
});
