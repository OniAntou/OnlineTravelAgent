# Booking Availability and Payment Cleanup Design

## Goal

Prevent hotel overbooking, remove MoMo completely, and retain cash only as an explicitly enabled non-production payment test gateway.

## Confirmed decisions

- A `Room` is a room type. `inventory` is the number of units of that type and defaults to `1`.
- A hotel booking reserves one unit for the half-open stay interval `[checkIn, checkOut)`. Two stays overlap when an existing check-in is before the requested check-out and its check-out is after the requested check-in.
- A cancelled Trip releases its reservation; every other hotel Trip consumes inventory until it is cancelled.
- Cash is a local/test gateway only. It may mark an owned Trip successful, but must not be shown in a normal release build unless `ALLOW_TEST_PAYMENTS=true` is supplied as a Dart define. The server remains disabled when `NODE_ENV=production`.
- MoMo is not a supported product surface and will be deleted from routes, controller code, mobile clients, environment examples, tests, and current documentation.

## Data model and concurrency

Add `Room.inventory Int @default(1)` and nullable `Trip.hotelCheckIn` / `Trip.hotelCheckOut` timestamp fields with an index covering room and stay dates. Existing rows receive inventory `1`; existing Trips keep null hotel dates and therefore do not participate in overlap counting.

Hotel booking parses the validated date-only input to UTC midnight, then runs an interactive PostgreSQL transaction. It locks the selected room (`FOR UPDATE`), counts non-cancelled hotel Trips whose structured intervals overlap the requested interval, and returns HTTP 409 when the count reaches inventory. The same transaction creates the Trip, persists the structured dates, and stores `room.price * nights`. The lock serializes bookings of the same room type and prevents two concurrent requests from both seeing the final available unit.

Partner and Admin room forms/API schemas expose `inventory` with a positive-integer constraint, so room types with multiple units can be configured deliberately.

## Payment boundary

VNPAY remains the only real digital-payment integration. It still requires configured provider credentials plus a sandbox return/IPN smoke test outside this repository before production release. Refund remains an explicit in-product simulation until a provider refund contract is authorized.

## Verification

Tests must first prove a conflicting second hotel booking is rejected, a cancelled booking frees inventory, and the cash test route cannot be reached in production. Add a widget test that release builds omit cash unless the Dart define is enabled. Run backend build/test/Prisma validation, Flutter analyze/test, and a migration check against the configured local database if available.
