import { describe, expect, it } from "vitest";
import {
  bookHotelSchema,
  bookTripSchema,
  bookTourSchema,
  customTourSchema,
  reviewSchema,
} from "../src/schemas/client.schema.js";

describe("client request schemas", () => {
  it("rejects negative prices", () => {
    const parsed = bookTourSchema.safeParse({
      tourId: "tour-1",
      date: "2026-08-01",
      guests: "2",
      totalPrice: -1,
    });

    expect(parsed.success).toBe(false);
  });

  it("requires date and guests when booking a destination trip", () => {
    const parsed = bookTripSchema.safeParse({
      destinationId: "dest-1",
      date: "",
      guests: "",
    });

    expect(parsed.success).toBe(false);
  });

  it("coerces numeric guest and rating values", () => {
    const tour = bookTourSchema.safeParse({
      tourId: "tour-1",
      date: "2026-08-01",
      guests: 2,
      totalPrice: "1000",
    });
    const review = reviewSchema.safeParse({
      targetType: "tour",
      targetId: "tour-1",
      rating: "5",
      comment: "Good",
    });

    expect(tour.success).toBe(true);
    expect(review.success).toBe(true);
  });

  it("accepts custom tour arrays sent by the Flutter client", () => {
    const parsed = customTourSchema.safeParse({
      destination: "Da Nang",
      location: "Da Nang",
      date: "2026-08-01",
      guests: "2",
      imagePath: "/images/da-nang.jpg",
      flightIds: ["flight-1"],
      hotelIds: ["hotel-1"],
      totalPrice: "1500",
    });

    expect(parsed.success).toBe(true);
  });

  it("accepts hotel dates sent as DD/MM/YYYY", () => {
    const parsed = bookHotelSchema.safeParse({
      roomId: "room-1",
      checkIn: "10/08/2026",
      checkOut: "12/08/2026",
      guests: "2",
    });

    expect(parsed.success).toBe(true);
  });

  it("rejects hotel checkout before or on checkin date", () => {
    const sameDay = bookHotelSchema.safeParse({
      roomId: "room-1",
      checkIn: "10/08/2026",
      checkOut: "10/08/2026",
      guests: "2",
    });
    const beforeCheckIn = bookHotelSchema.safeParse({
      roomId: "room-1",
      checkIn: "10/08/2026",
      checkOut: "09/08/2026",
      guests: "2",
    });

    expect(sameDay.success).toBe(false);
    expect(beforeCheckIn.success).toBe(false);
  });
});
