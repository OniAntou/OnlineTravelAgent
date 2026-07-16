# Runtime and Dataflow Optimization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove avoidable data-store probes and bootstrap work while making cache invalidation, schedule batching, and trip status deterministic.

**Architecture:** Backend owns short-lived persistent-data availability and a narrow bootstrap base cache. Flutter hands a single fetched bootstrap payload to a snapshot writer that deletes only stale IDs and rehydrates rooms in bulk. `TripStatus` is the common type between JSON adapters, Drift text storage, providers, and UI.

**Tech Stack:** TypeScript, Express 5, Prisma, NodeCache, Vitest, Flutter, Riverpod, Drift/SQLite, flutter_test.

---

### Task 1: Centralize persistent-data availability

**Files:**

- Modify: `backend/src/core/config/data-availability.ts`
- Modify: `backend/src/app.ts`
- Modify: `backend/src/modules/auth/auth.controller.ts`
- Modify: `backend/src/modules/auth/token.service.ts`
- Modify: `backend/src/modules/trips/data/trip.store.ts`
- Modify: `backend/src/modules/client/data/document.store.ts`
- Modify: `backend/src/modules/catalog/data/review.store.ts`
- Modify: `backend/src/modules/catalog/data/hotel.store.ts`
- Create: `backend/tests/core/data-availability.test.ts`

- [x] **Step 1: Add failing availability-cache tests**

```ts
expect(await isPersistentDataAvailable()).toBe(true);
expect(await isPersistentDataAvailable()).toBe(true);
expect(mocks.queryRaw).toHaveBeenCalledTimes(1);
```

- [x] **Step 2: Implement the shared probe and fallback decision**

```ts
export async function shouldUseMemoryFallback(): Promise<boolean> {
  if (await isPersistentDataAvailable()) return false;
  assertMemoryFallbackEnabled();
  return true;
}
```

- [x] **Step 3: Replace every mutation preflight helper with `shouldUseMemoryFallback` and use a forced probe for `/health`**

```ts
if (await shouldUseMemoryFallback()) {
  return memoryDbOperation();
}
```

- [x] **Step 4: Run focused tests**

Run: `npm test -- --run tests/core/data-availability.test.ts tests/core/production-data-availability.test.ts`
Expected: all selected Vitest tests pass.

### Task 2: Scope cache invalidation to bootstrap base data

**Files:**

- Modify: `backend/src/core/config/cache.ts`
- Modify: `backend/src/modules/routes.ts`
- Modify: `backend/src/modules/admin/admin.routes.ts`
- Modify: `backend/src/modules/partner/partner.routes.ts`
- Modify: `backend/src/modules/client/client.routes.ts`
- Create: `backend/tests/core/cache.test.ts`

- [x] **Step 1: Write a test preserving unrelated cache entries**

```ts
appCache.set(BOOTSTRAP_BASE_KEY, { destinations: [] });
appCache.set("search:da-lat", { destinations: [] });
invalidateBootstrapBaseCache();
expect(appCache.get(BOOTSTRAP_BASE_KEY)).toBeUndefined();
expect(appCache.get("search:da-lat")).toBeDefined();
```

- [x] **Step 2: Delete only `BOOTSTRAP_BASE_KEY` after successful catalogue/review mutations**

```ts
adminRouter.post("/destinations", invalidateBootstrapBaseOnMutation, validate(...), controller);
clientRouter.post("/reviews", invalidateBootstrapBaseOnMutation, clientAuth, validate(...), controller);
```

- [x] **Step 3: Remove the global client mutation invalidator**

```ts
routes.use("/", generalLimiter, clientRouter);
```

- [x] **Step 4: Run focused cache tests**

Run: `npm test -- --run tests/core/cache.test.ts tests/modules/client/bootstrap-store.test.ts`
Expected: base data invalidates without evicting search cache.

### Task 3: Reuse bootstrap data and incrementally persist snapshot

**Files:**

- Modify: `lib/app/state/app_state_provider.dart`
- Modify: `lib/data/services/sync_service.dart`
- Modify: `lib/data/local/daos/hotels_dao.dart`
- Modify: `test/data/services/sync_service_test.dart`
- Create: `test/app/state/app_state_provider_test.dart`

- [x] **Step 1: Add tests for one bootstrap fetch, stale-row removal, and room hydration**

```dart
await container.read(bootstrapProvider.future);
expect(api.bootstrapFetchCount, 1);
expect(cached.hotels.single.rooms, hasLength(1));
```

- [x] **Step 2: Expose `persistBootstrap(BootstrapData)` and make `syncAll` reuse the same private persistence path**

```dart
final fresh = await api.fetchBootstrap();
await syncService.persistBootstrap(fresh);
return fresh;
```

- [x] **Step 3: Replace table wipes with stale-ID deletion plus existing upserts, and bulk-load rooms once**

```dart
final roomsByHotel = groupBy(await db.hotelsDao.getAllRooms(), (room) => room.hotelId);
```

- [x] **Step 4: Run focused Flutter tests**

Run: `flutter test test/app/state/app_state_provider_test.dart test/data/services/sync_service_test.dart`
Expected: fresh payload is fetched once and SQLite rehydrates correctly.

### Task 4: Enforce schedule batch contract and linear server grouping

**Files:**

- Modify: `lib/data/remote/trip_api_service.dart`
- Modify: `backend/src/modules/trips/schedule.service.ts`
- Modify: `backend/tests/modules/trips/schedule-service.test.ts`
- Create: `test/data/remote/trip_api_service_test.dart`

- [x] **Step 1: Test chunk boundaries and grouped result semantics**

```dart
expect(chunkTripScheduleIds(List.generate(51, (i) => '$i')).map((c) => c.length), [50, 1]);
```

```ts
expect(result["trip-1"].days).toEqual([dayOne]);
expect(result["trip-2"].updates).toEqual([updateTwo]);
```

- [x] **Step 2: Implement client chunking and merge chunk responses**

```dart
for (final ids in chunkTripScheduleIds(uniqueIds)) {
  result.addAll(await _fetchTripSchedulesBatchChunk(ids));
}
```

- [x] **Step 3: Group Prisma rows once by `tripId` on the server**

```ts
const daysByTrip = Map.groupBy(allDays, (day) => day.tripId);
```

- [x] **Step 4: Run schedule tests**

Run: `npm test -- --run tests/modules/trips/schedule-service.test.ts` and `flutter test test/data/remote/trip_api_service_test.dart`
Expected: 51 IDs become 50+1 client chunks and server returns each owned trip’s rows.

### Task 5: Make `TripStatus` canonical end-to-end

**Files:**

- Modify: `lib/features/trips/domain/trip.dart`
- Modify: `lib/data/services/sync_service.dart`
- Modify: `lib/data/local/daos/trips_dao.dart`
- Modify: `lib/features/trips/application/trip_provider.dart`
- Modify: `lib/features/trips/presentation/widgets/trip_card.dart`
- Modify: `lib/features/trips/presentation/widgets/trip_action_buttons.dart`
- Modify: `lib/features/trips/presentation/widgets/trip_schedule_timeline.dart`
- Modify: `lib/features/trips/presentation/widgets/booking_status_timeline.dart`
- Modify: `lib/features/trips/presentation/place_trip_detail_screen.dart`
- Modify: `lib/features/trips/presentation/tour_trip_detail_screen.dart`
- Modify: `lib/features/notifications/presentation/notifications_screen.dart`
- Modify: `test/shared/models/model_test.dart`
- Modify: `test/data/services/sync_service_test.dart`
- Modify: `test/features/trips/trip_provider_test.dart`
- Modify: `test/helpers/test_helpers.dart`

- [x] **Step 1: Add parser and legacy-storage tests**

```dart
expect(TripStatus.fromServer('ONGOING', 'PENDING', true), TripStatus.pendingPayment);
expect(TripStatus.fromStorage('Đã hủy', false), TripStatus.cancelled);
```

- [x] **Step 2: Add enum adapters and persist `storageValue` in Drift**

```dart
status: Value(trip.status.storageValue),
status: TripStatus.fromStorage(row.status, row.isUpcoming),
```

- [x] **Step 3: Replace text comparisons with enum comparisons and render only `displayLabel`**

```dart
if (trip.status != TripStatus.cancelled && trip.isUpcoming) { ... }
```

- [x] **Step 4: Run status-focused Flutter tests**

Run: `flutter test test/shared/models/model_test.dart test/data/services/sync_service_test.dart test/features/trips/trip_provider_test.dart`
Expected: legacy rows normalize, provider filters use enum, and UI consumers compile.

### Task 6: Document and verify the integrated change

**Files:**

- Modify: `docs/architecture/README.md`
- Modify: `docs/architecture/backend-and-api.md`
- Modify: `docs/architecture/mobile-client.md`
- Modify: `docs/workflows/README.md`
- Modify: `docs/workflows/sync-and-realtime.md`
- Modify: `docs/workflows/operations-and-release.md`

- [x] **Step 1: Update architecture and workflow links with the implemented contracts**

```markdown
Bootstrap fetches one payload per foreground load; snapshot persistence receives that payload directly.
```

- [x] **Step 2: Run repository verification**

Run: `npm run db:validate`, `npm run build`, `npm test` from `backend`; then `flutter analyze` and `flutter test` from repository root.
Expected: all commands exit 0.
