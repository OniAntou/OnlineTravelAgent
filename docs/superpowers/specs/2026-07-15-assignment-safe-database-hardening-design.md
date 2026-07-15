# Assignment-Safe Database Hardening Design

## Goal

Harden the existing PostgreSQL schema for a coursework application without
deleting the newly created account, seed catalogue, or changing the Flutter
payloads that already depend on display-oriented text fields.

## Scope

This delivery strengthens data integrity, sandbox-payment idempotency, and
read-query indexes while keeping the current single-`Trip` booking model.

- Preserve all existing rows through a custom Prisma migration.
- Convert event timestamps from `timestamp(3)` to `timestamptz(3)` using UTC,
  which matches the stored values in the live database.
- Add database-level foreign keys, enums, `CHECK` constraints, partial unique
  indexes, and composite indexes where the current API already needs them.
- Keep payment providers in sandbox mode. No production credentials, charges,
  refund workflow, or production-payment architecture is introduced.
- Update backend code only where it must respect a new database rule, such as
  cleanly deleting reviews before deleting their polymorphic target.

The delivery deliberately does not split `Trip` into `Booking`, `BookingItem`,
and `PaymentTransaction`, create a separate least-privilege PostgreSQL runtime
role, or introduce cloud backup automation. Those are production-scale concerns
outside this coursework-safe change.

## Compatibility Decisions

### Preserve display-oriented trip data

Existing trip rows store values such as `Hôm nay - 3 Ngày nữa` and
`2 Người lớn, 1 Trẻ em`. These are presentation snapshots rather than safely
parseable dates or quantities. The migration will retain `trips.date` and
`trips.guests` as text and will not add mandatory typed replacements in this
delivery.

Flight times (`HH:mm`), tour duration (`3N/2Đ`), destination review-count
labels (`2.5k`), and catalogue ratings remain API-compatible text fields where
the Flutter cache currently expects strings. The schema will validate only
values that can be enforced without changing the payload contract.

### Preserve the meaning of timestamps

Live application timestamps are UTC values stored in timezone-less columns.
Each event-time column will be altered with `USING column AT TIME ZONE 'UTC'`
so the represented instant remains unchanged when it becomes `timestamptz(3)`.
This includes creation, update, expiry, revocation, and promotion-validity
timestamps. `trip_schedule_days.date` remains unchanged because it represents
an itinerary calendar day rather than an event instant.

## Schema Changes

### Category relationship

`destinations.category` will remain a string so Flutter payloads do not change,
but it will reference the existing unique `categories.name` column. The
migration first verifies every destination category has a matching row, then
adds the foreign key with `ON DELETE RESTRICT` and `ON UPDATE CASCADE`.

Prisma will expose the relation as a category record without removing the
existing `category` scalar. The admin category-delete endpoint will return a
clear conflict response rather than leaving an unhandled foreign-key failure.

### Review and schedule integrity

- Add a `ReviewTargetType` enum with `destination`, `hotel`, `tour`, and
  `flight`, converting existing valid `reviews.target_type` values.
- Add `CHECK (rating BETWEEN 1 AND 5)` to `reviews`.
- Retain the polymorphic review design for the assignment, but delete matching
  reviews in the same transaction before an admin deletes a destination,
  hotel, tour, or flight. This prevents orphan reviews even though a single
  polymorphic foreign key is not possible in PostgreSQL.
- Add a `ScheduleSourceType` enum with `tour` and `destination`.
- Add a `CHECK` constraint requiring exactly one source foreign key and a
  matching `source_type` for every schedule template.

### Numeric and promotion constraints

Add named checks that reject negative money values, non-positive room capacity,
out-of-range text ratings, invalid promotion bounds, and inconsistent trip
discounts. Current data passes all of these preflight checks.

Promotion checks require exactly one discount form, a percentage in the range
`(0, 100]`, non-negative monetary discounts and usage counts, and
`current_uses <= max_uses`. The current promo feature remains sandbox/demo
only; a future redemption flow must atomically consume a promotion inside the
booking transaction instead of using a check-then-increment sequence.

### Sandbox-payment safety

Add partial unique indexes for non-null sandbox transaction references scoped
by payment method. They allow repeated callbacks for the same trip while
preventing the same provider reference from being attached to two trips.
Existing data is checked for duplicates before the indexes are created.

### Query indexes

Add only indexes backed by existing read paths:

- `trips (user_id, created_at DESC)`
- `document_items (user_id, created_at DESC)`
- `reviews (target_type, target_id, created_at DESC)`
- `trip_schedule_updates (trip_id, created_at DESC)`
- `schedule_template_items (day_id, sort_order, start_time)`
- `trip_schedule_items (day_id, sort_order, start_time)`

Full-text search indexing and catalogue pagination stay out of this delivery.
The live catalogue is small, and adding a GIN index without first aligning the
exact Prisma search expression would create unused index overhead.

## Migration Safety

The custom SQL migration will execute in this order:

1. Run preflight `DO` blocks that abort if existing rows would violate a new
   foreign key, enum conversion, check, or unique index.
2. Create enum types and convert the two validated text discriminator columns.
3. Convert event timestamps from UTC `timestamp(3)` to `timestamptz(3)`.
4. Add category foreign key, named checks, partial unique indexes, and composite
   indexes.
5. Run `ANALYZE` for the affected tables so the new indexes have current table
   statistics after the seed rebuild.

No `DROP TABLE`, `TRUNCATE`, data reset, or destructive column replacement is
permitted. The verified backup at `D:\OnlineTravelAgentBackups` remains the
rollback safety copy before applying the migration.

## Backend Changes

- Update Prisma schema declarations for the new enums, category relation,
  timestamptz columns, checks represented in migration SQL, and composite/
  partial index metadata where Prisma supports it.
- Update review target types so TypeScript uses the generated enum rather than
  unconstrained strings at write boundaries.
- Wrap catalogue deletion and matching review cleanup in short Prisma
  transactions.
- Translate a restricted category deletion into an HTTP 409 response.
- Keep VNPAY/MoMo endpoints in sandbox configuration and retain their existing
  signature verification flow.

The Flutter API contract, Drift cache schema, and local snapshot data remain
unchanged because response field names and display-oriented field types do not
change.

## Verification

1. Confirm the backup file exists before migration.
2. Run `npm run db:validate`, apply the migration, and run
   `npx prisma migrate status`.
3. Query the live database to confirm the account, seed row counts, foreign-key
   coverage, zero orphan reviews, zero invalid templates, and timestamp types.
4. Run focused Vitest coverage for admin deletion, review creation, schedules,
   promotions, and payment callbacks, then run `npm test` and `npm run build`.
5. Run Flutter analysis/tests and launch the emulator to verify login, bootstrap,
   favorites, trip lists, schedule display, and sandbox payment status still
   load correctly.

## Acceptance Criteria

- Existing account and seed data remain intact after migration.
- PostgreSQL itself rejects invalid reviews, schedule sources, negative prices,
  invalid promotion values, and duplicate sandbox transaction references.
- Deleting a catalogue item cannot leave a review pointing to it.
- The current Flutter app receives the same JSON field names and display text as
  before the hardening.
- Migration, backend tests/build, Flutter checks, and live emulator smoke test
  pass.
