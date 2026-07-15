# Assignment-safe database hardening Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Harden the local PostgreSQL schema and its backend mutation paths for the coursework application without introducing real payment processing or changing the existing Flutter payload contracts.

**Architecture:** Keep the current Prisma/PostgreSQL design and add a forward-only SQL migration for database-only guarantees Prisma cannot express. Align Prisma types and the admin controller with those guarantees, then cover destructive catalogue operations and validate both migration and application behavior against the real local database.

**Tech Stack:** PostgreSQL 18, Prisma 6, Node.js/TypeScript, Fastify, Vitest, Flutter.

---

## Scope and safety boundaries

- [ ] Preserve existing users, catalogue rows, trips, schedules, and Flutter-facing text fields such as `Trip.date`, `Trip.guests`, `Flight.duration`, `Flight.time`, and `TourPackage.departureDate`.
- [ ] Keep all payment integrations sandbox-only. Do not add live-provider credentials, checkout URLs, or a real-money redemption flow.
- [ ] Treat all existing `timestamp without time zone` event values as UTC before converting them to `timestamptz`.
- [ ] Apply the migration only after checking all preconditions against `online_travel_agent`, and keep the verified pre-change dump available for rollback.

## 1. Create a guarded forward-only migration

**Files:**
- Create: `backend/prisma/migrations/20260715233000_assignment_safe_database_hardening/migration.sql`
- Modify: `backend/prisma/schema.prisma`

- [ ] Add SQL preflight guards that abort before DDL if a destination category has no matching category name, a review target/rating is invalid, a schedule source shape is invalid, guarded numeric values are invalid, or a sandbox transaction reference/number is duplicated within one payment method.
- [ ] Create `ReviewTargetType` (`destination`, `hotel`, `tour`, `flight`) and `ScheduleSourceType` (`tour`, `destination`) enums, then convert `reviews.target_type` and `schedule_templates.source_type` with explicit `USING ...::text::enum` casts.
- [ ] Add the destination-category foreign key to `categories.name`, rating/price/capacity/promotion/trip checks, and the schedule-template exactly-one-source check using stable constraint names.
- [ ] Convert event timestamp columns to `TIMESTAMPTZ(3)` with `AT TIME ZONE 'UTC'`. Include only actual instants: user, token, trip, document, review, schedule-template, schedule-update, notification, and payment timestamps. Leave schedule-day calendar dates untouched.
- [ ] Add partial unique indexes for non-null sandbox payment references and transaction numbers scoped by payment method.
- [ ] Add composite indexes used by current read paths: user trips/documents, reviews by target and newest-first, trip updates by trip and newest-first, and ordered schedule items.
- [ ] Add the corresponding Prisma enum declarations, relations, `@db.Timestamptz(3)` annotations, and mapped indexes so `prisma migrate status` stays aligned with the deployed schema.
- [ ] Finish the migration with `ANALYZE` for the changed, query-critical tables.

## 2. Keep polymorphic review cleanup transactional

**Files:**
- Modify: `backend/src/modules/admin/admin.controller.ts`
- Modify: `backend/src/modules/catalog/data/review.store.ts`
- Modify: `backend/src/modules/trips/schedule.service.ts`

- [ ] Use Prisma-generated `ReviewTargetType` and `ScheduleSourceType` values instead of duplicated string unions where these types cross persistence boundaries.
- [ ] Add one controller helper that removes reviews for a target through the transaction client.
- [ ] Change destination, hotel, flight, and tour deletion handlers to delete target reviews and the target row in one transaction. Preserve existing room cleanup for hotels.
- [ ] Replace direct category deletion with a lookup that returns `404` for an absent category and `409` when destinations still reference it; delete only unreferenced categories.
- [ ] Keep existing response bodies and route shapes unchanged for successful deletion.

## 3. Add focused regression coverage

**Files:**
- Create: `backend/tests/modules/admin/admin-catalog-deletion.test.ts`
- Modify: `backend/tests/modules/admin/admin-hotel-deletion.test.ts`

- [ ] Extend the hotel-deletion test to assert review cleanup occurs before rooms and hotel records are removed inside the same transaction.
- [ ] Add controller-route tests for destination, flight, and tour deletions to assert the matching enum target and ID are passed to review cleanup.
- [ ] Add a category-delete test that expects `409` and confirms no delete happens while `_count.destinations` is non-zero, plus a successful empty-category deletion case.
- [ ] Retain existing review-target, payment-security, and schedule-service tests as regression coverage for the enum/type migration.

## 4. Verify in increasing-risk order

**Commands (run from `backend/` unless noted):**

```powershell
npm run db:validate
npx prisma migrate status
npm test -- --run tests/modules/admin/admin-hotel-deletion.test.ts tests/modules/admin/admin-catalog-deletion.test.ts tests/modules/catalog/review-target.test.ts tests/modules/payment/payment-security.test.ts tests/modules/trips/schedule-service.test.ts
npm run build
npm test
```

- [ ] Query PostgreSQL after migration to verify all listed event columns use `timestamp with time zone`, all named checks and partial unique indexes exist, all valid pre-existing rows remain, and the expected new composite indexes are present.
- [ ] Query the retained account and catalogue totals before/after migration, including the user created by the user, to ensure the migration did not drop application data.
- [ ] Run `ANALYZE` verification through PostgreSQL statistics or a direct completion check.
- [ ] Start the local backend and perform a sandbox payment security smoke test using the existing test route or test suite; do not invoke any live payment provider.
- [ ] Run `flutter analyze` from the mobile application directory and launch the already configured emulator for a login/catalogue smoke check if Flutter tooling is available.

## 5. Review and hand off

- [ ] Inspect `git diff --check`, staged diff, Prisma migration status, and test/build output.
- [ ] Commit the implementation separately from this plan with a message that states the schema hardening scope.
- [ ] Report the exact migration name, verified account/catalogue preservation, remaining intentionally deferred coursework limits, and whether the implementation has been pushed.

## Acceptance criteria

- [ ] Existing local data is still present after the migration, and the retained account can still authenticate through the current application flow.
- [ ] Database rejects invalid category, review, schedule-source, amount, capacity, promotion, and sandbox transaction-identity states described above.
- [ ] Realtime event timestamps are timezone-aware without changing stored moments.
- [ ] Admin deletion cannot leave reviews behind for destination, hotel, tour, or flight targets; category deletion cannot orphan destinations.
- [ ] The backend builds, focused and full tests pass, Prisma reports the schema as up to date, and the Flutter static check passes when tooling is available.
