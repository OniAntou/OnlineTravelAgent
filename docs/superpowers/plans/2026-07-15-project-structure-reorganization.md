# Project Structure Reorganization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reorganize the Flutter client, Express backend, tests, and review
artifacts into clear ownership boundaries without changing application behavior.

**Architecture:** Flutter moves from top-level technical folders to `app`,
`core`, `data`, `features`, and `shared`; each feature owns its presentation,
state, and domain files. The backend keeps `app.ts` and `server.ts` as
composition roots while moving shared code into `core`, persistence/fallback
code into `infrastructure`, and endpoint code into domain modules. All path
updates are mechanical and verified by the existing regression suites.

**Tech Stack:** Flutter, Riverpod, Drift, Dart analyzer/test, TypeScript,
Express, Prisma, Vitest, PowerShell, Git.

---

### Task 1: Preserve project-root hygiene and documentation

**Files:**
- Modify: `.gitignore` remains unchanged.
- Move: `ANTIGRAVITY_REVIEW.md` -> `docs/reviews/2026-07-15-antigravity-refactor-review.md`
- Delete: `logcat.txt`
- Create: `docs/superpowers/plans/2026-07-15-project-structure-reorganization.md`
- Modify: `docs/superpowers/specs/2026-07-15-project-structure-reorganization-design.md`

- [ ] **Step 1: Verify that only the untracked debug log is outside the branch baseline.**

Run: `git status -sb`

Expected: the tracked tree contains only the approved design/plan work and
`logcat.txt` is the only pre-existing untracked root artifact.

- [ ] **Step 2: Move the tracked review into the date-based review folder and remove the root log.**

Run:

```powershell
New-Item -ItemType Directory -Force docs/reviews | Out-Null
git mv ANTIGRAVITY_REVIEW.md docs/reviews/2026-07-15-antigravity-refactor-review.md
Remove-Item -LiteralPath logcat.txt
git add -f -- docs/reviews/2026-07-15-antigravity-refactor-review.md
```

Expected: the root no longer contains review or log artifacts; `.gitignore`
continues to ignore unrelated agent documentation.

- [ ] **Step 3: Verify the documentation-only change and commit it.**

Run:

```powershell
git diff --check
git diff --cached --check
git commit -m "chore: organize project documentation"
```

Expected: the commit contains the review rename and no source file changes.

### Task 2: Move Flutter foundation, data, and shared code

**Files:**
- Move: `lib/database/**` -> `lib/data/local/**`
- Move: `lib/services/api/**` -> `lib/data/remote/**`
- Move: `lib/services/{connectivity_service,realtime_room_registry,sync_service,travel_api_service}.dart` -> `lib/data/services/`
- Move: `lib/providers/api_provider.dart` -> `lib/data/services/api_provider.dart`
- Move: `lib/providers/app_state_provider.dart` -> `lib/app/state/app_state_provider.dart`
- Move: `lib/utils/**` -> `lib/core/utils/**`
- Move: `lib/widgets/**` -> `lib/shared/widgets/**`
- Modify: all Dart source and test imports that reference the moved paths.

- [ ] **Step 1: Build an old-to-new path manifest before moving files.**

The manifest must map every `.dart` file under the listed directories. It uses
package imports as the canonical key, for example:

```text
lib/database/app_database.dart -> lib/data/local/app_database.dart
lib/services/api/api_http_client.dart -> lib/data/remote/api_http_client.dart
lib/services/sync_service.dart -> lib/data/services/sync_service.dart
lib/widgets/app_image.dart -> lib/shared/widgets/app_image.dart
```

- [ ] **Step 2: Apply Git-aware moves and rewrite only resolved Dart imports.**

For every moved file, resolve a package import from its old path to the mapped
new path. For a relative import, resolve its target from the old importer path,
look it up in the manifest, and calculate a new relative path from the new
importer path. Leave third-party imports and unresolved string literals intact.

Run after the rewrite:

```powershell
dart format lib test
flutter analyze
flutter test test/data test/shared test/core
```

Expected: Dart reports no old `database/`, `services/`, `utils/`, or top-level
`widgets/` package imports in `lib/` or `test/`.

- [ ] **Step 3: Commit the verified foundation move.**

Run:

```powershell
git diff --check
git add lib test
git commit -m "refactor: organize Flutter foundation layers"
```

Expected: the commit consists of file renames and import-path changes only.

### Task 3: Collocate Flutter features and their tests

**Files:**
- Move presentation folders:
  - `lib/screens/auth/**` -> `lib/features/auth/presentation/**`
  - `lib/screens/{destinations,destination_detail}/**` -> `lib/features/destinations/presentation/**`
  - `lib/screens/tours/**` -> `lib/features/tours/presentation/**`
  - `lib/screens/hotels/**` -> `lib/features/hotels/presentation/**`
  - `lib/screens/flights/**` -> `lib/features/flights/presentation/**`
  - `lib/screens/checkout/**` -> `lib/features/booking/presentation/**`
  - `lib/screens/my_trips/**` -> `lib/features/trips/presentation/**`
  - `lib/screens/{profile,favorites,partner,search,dashboard,notifications,welcome,food}/**` -> the matching `lib/features/<feature>/presentation/**`
  - `lib/screens/main/main_screen.dart` -> `lib/app/shell/main_screen.dart`
- Move domain and application files:
  - `destination.dart` and `destination_provider.dart` -> `features/destinations/{domain,application}/`
  - `tour_package.dart` and `tour_provider.dart` -> `features/tours/{domain,application}/`
  - `hotel.dart`, `room.dart`, and `hotel_provider.dart` -> `features/hotels/{domain,application}/`
  - `flight.dart` and `flight_provider.dart` -> `features/flights/{domain,application}/`
  - `trip.dart`, `trip_schedule.dart`, `trip_provider.dart`, and `trip_schedule_provider.dart` -> `features/trips/{domain,application}/`
  - `user_profile.dart`, `document_item.dart`, and `profile_provider.dart` -> `features/profile/{domain,application}/`
  - `auth_provider.dart` -> `features/auth/application/auth_provider.dart`
  - `review.dart` -> `lib/shared/models/review.dart`
- Move matching Flutter tests into `test/features/<feature>/`, `test/shared/`, or `test/app/`.

- [ ] **Step 1: Move isolated UI features first.**

Move `auth`, `dashboard`, `welcome`, `notifications`, `food`, and the app shell;
rewrite imports using the same manifest algorithm from Task 2.

Run:

```powershell
flutter test test/features/auth test/app
flutter analyze
```

- [ ] **Step 2: Move catalog and booking features.**

Move destinations, tours, hotels, flights, booking, and their models/providers.
Preserve GoRouter paths, checkout callbacks, and `TravelApiService` public
symbols exactly; directory names are the only intended change.

Run:

```powershell
flutter test test/features/destinations test/features/tours
flutter analyze
```

- [ ] **Step 3: Move trips, profile, favorites, partner, and search.**

Move `my_trips` as the `trips` feature and move its schedule models/providers
with the presentation widgets. Keep `review.dart` under `shared/models` because
it is consumed by more than one feature.

Run:

```powershell
flutter test test/features/trips test/features/profile
flutter analyze
flutter test
```

- [ ] **Step 4: Commit the verified feature migration.**

Run:

```powershell
git diff --check
git add lib test
git commit -m "refactor: group Flutter code by feature"
```

Expected: no active `lib/screens`, `lib/models`, or broad `lib/providers`
directory remains.

### Task 4: Move backend shared and infrastructure code

**Files:**
- Move: `backend/src/config/{cache,data-availability,env}.ts` -> `backend/src/core/config/`
- Move: `backend/src/config/prisma.ts` -> `backend/src/infrastructure/database/prisma.ts`
- Move: `backend/src/middlewares/**` -> `backend/src/core/middleware/**`
- Move: `backend/src/{types,utils,validators}/**` -> `backend/src/core/{types,utils,validators}/**`
- Move: `backend/src/data/mock-data.ts` -> `backend/src/infrastructure/fallback/mock-data.ts`
- Move: `backend/src/store/memory-db.ts` -> `backend/src/infrastructure/fallback/memory-db.ts`
- Move: `backend/src/store/helpers.ts` -> `backend/src/core/data/store-helpers.ts`
- Modify: resolved relative module-specifier strings in `backend/src/**` and `backend/tests/**`.

- [ ] **Step 1: Build a TypeScript old-to-new path manifest.**

Keys are source `.ts` paths; imports retain NodeNext `.js` extensions. For
example:

```text
src/config/prisma.ts -> src/infrastructure/database/prisma.ts
src/middlewares/auth.ts -> src/core/middleware/auth.ts
src/store/memory-db.ts -> src/infrastructure/fallback/memory-db.ts
```

- [ ] **Step 2: Rewrite resolved relative module strings mechanically.**

For every moved TypeScript file and test, resolve a quoted relative string from
the original importer path. If its target is in the manifest, calculate the
new relative module specifier and keep the original `.js` extension. Apply the
same rule to `vi.mock(...)` strings, not only `import` declarations.

Run:

```powershell
npm run db:validate
npm run build
npm test
```

Expected: build resolution succeeds without path aliases or runtime loaders.

- [ ] **Step 3: Commit the verified shared-code migration.**

Run:

```powershell
git diff --check
git add backend/src backend/tests
git commit -m "refactor: organize backend shared layers"
```

### Task 5: Group backend endpoint code and tests by module

**Files:**
- Move auth files: `auth.controller.ts`, `auth.routes.ts`, `auth.schema.ts`, `password.service.ts`, and `token.service.ts` -> `backend/src/modules/auth/`
- Move admin files: `admin.controller.ts`, `admin.routes.ts`, and `admin.schema.ts` -> `backend/src/modules/admin/`
- Move client files: `client.controller.ts`, `client.routes.ts`, `client.schema.ts`, `bootstrap.store.ts`, `document.store.ts`, and `store/index.ts` -> `backend/src/modules/client/`
- Move partner files: `partner.controller.ts` and `partner.routes.ts` -> `backend/src/modules/partner/`
- Move payment files: `payment.controller.ts`, `payment.routes.ts`, and `vnpay.service.ts` -> `backend/src/modules/payment/`
- Move booking files: `booking-idempotency.ts` -> `backend/src/modules/booking/data/`
- Move catalog files: `hotel.store.ts`, `promo.store.ts`, `review.store.ts`, `search.store.ts`, and `tour.store.ts` -> `backend/src/modules/catalog/data/`
- Move trips files: `trip.store.ts`, `schedule.service.ts`, `schedule-realtime.ts`, and `seed_schedules.ts` -> `backend/src/modules/trips/`
- Move route composition: `backend/src/routes/index.ts` -> `backend/src/modules/routes.ts`
- Move each `backend/tests/*.test.ts` into `backend/tests/<module>/` based on its exercised module.

- [ ] **Step 1: Move auth, admin, client, partner, and payment modules.**

Keep `app.ts` as the only Express composition root and update it to import
`modules/routes.js`. Preserve all mounted HTTP paths and auth middleware order.

Run:

```powershell
npm test
npm run build
```

- [ ] **Step 2: Move booking, catalog, and trips modules.**

Keep database access and fallback behavior unchanged. Move the test files with
their owning module and rewrite their relative source imports and mocks.

Run:

```powershell
npm test
npm run db:validate
npm run build
npm test
```

- [ ] **Step 3: Commit the verified module migration.**

Run:

```powershell
git diff --check
git add backend/src backend/tests
git commit -m "refactor: group backend code by module"
```

Expected: no active root-level `controllers`, `routes`, `schemas`, `services`,
or `store` directory remains under `backend/src`.

### Task 6: Final tree and runtime verification

**Files:**
- Modify: imports or documentation links only when final verification exposes a path error.

- [ ] **Step 1: Scan for stale paths and duplicate active files.**

Run:

```powershell
rg -n 'package:online_travel_agent/(screens|models|providers|services|widgets|utils|database)/' lib test
rg -n '\.\.?/(controllers|routes|schemas|services|store|config|middlewares|types|utils)/' backend/src backend/tests
git diff --check
```

Expected: no stale source path is reported; third-party references and generated
files are unchanged.

- [ ] **Step 2: Run the full regression suite from the correct working directories.**

Run at repository root:

```powershell
flutter analyze
flutter test
git diff --check
```

Run from `backend/`:

```powershell
npm run db:validate
npm run build
npm test
```

- [ ] **Step 3: Perform the existing smoke flow.**

Verify login/logout, cached bootstrap fallback, token refresh, booking handoff,
back navigation, and Socket.IO reconnect. Record any behavior regression as a
separate fix instead of mixing it into the structural commits.

- [ ] **Step 4: Confirm branch cleanliness and summarize the structural commits.**

Run:

```powershell
git status -sb
git log --oneline main..HEAD
```

Expected: only intentional commits and no temporary script or root log remain.
