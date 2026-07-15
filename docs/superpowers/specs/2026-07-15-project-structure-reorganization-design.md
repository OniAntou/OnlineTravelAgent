# Project Structure Reorganization Design

## Goal

Make the Flutter client, Express backend, tests, and project documentation
easier to navigate by grouping code by ownership and domain. The migration must
preserve runtime behavior, public API contracts, database schema, and existing
test coverage.

## Scope

This is a structure-only refactor.

- Move source and test files with their unchanged contents whenever possible.
- Update imports, exports, route registrations, test paths, and documentation
  links required by those moves.
- Keep generated files, package manifests, platform folders, and runtime
  behavior unchanged.
- Move `ANTIGRAVITY_REVIEW.md` into `docs/reviews/` with a date-based name.
- Remove the untracked `logcat.txt` debug capture from the repository root.

The migration does not introduce repositories, new state-management patterns,
new dependencies, API endpoints, database migrations, route behavior changes,
or UI redesigns. The previously identified Bootstrap, routing, and TourDetail
refactors remain separate follow-up work.

## Target Structure

### Project root

```text
docs/
  reviews/
  superpowers/
backend/
lib/
test/
assets/
android/ ios/ web/ windows/
```

The hidden tool and CI folders (`.agents`, `.codex`, `.github`, `.opencode`,
and `.vscode`) remain at the root. They are configuration boundaries, not
application source.

### Flutter client

```text
lib/
  app/                         # application bootstrap and composition
  core/                        # router, theme, constants, errors, generic utilities
  data/
    local/                     # Drift database, tables, and DAOs
    remote/                    # HTTP client and backend API services
    services/                  # connectivity, sync, realtime, compatibility facade
  features/
    auth/
    destinations/
    tours/
    hotels/
    flights/
    booking/
    trips/
    profile/
    favorites/
    partner/
    search/
    dashboard/
    notifications/
    welcome/
  shared/
    widgets/                   # truly cross-feature presentation widgets
```

Each feature owns its presentation files, feature-only widgets, providers, and
domain models. A model or utility remains in `core`, `data`, or `shared` only
when it has genuine cross-feature ownership. The current `TravelApiService`
remains a compatibility facade under `data/services`; this migration does not
delete or redesign it.

`test/` mirrors the same boundaries:

```text
test/
  core/
  data/
  features/<feature>/
  shared/widgets/
  helpers/
```

### Express backend

```text
backend/src/
  core/                        # config, middleware, common types and utilities
  infrastructure/              # Prisma integration and fallback/mock data
  modules/
    routes.ts                  # single route-composition boundary
    auth/
    admin/
    client/
    partner/
    payment/
    booking/
    catalog/
    trips/
  app.ts
  server.ts
```

Each module contains the controller, route definition, schema, service, and
store code that it owns. Code shared by multiple modules belongs in `core`;
database and fallback-data implementation belongs in `infrastructure`. The
module route files are aggregated by `modules/routes.ts` and mounted by
`app.ts`. No legacy root-level `routes/` directory remains after its contents
are moved.

`backend/tests/` is grouped by the matching module, with cross-cutting tests
under `backend/tests/core/` or `backend/tests/infrastructure/`.

## Migration Rules

1. Use Git-aware moves so history remains recoverable; do not copy a source
   file and leave a second active version behind.
2. Change only paths and import/export references during a structural commit.
   Any required behavior change is stopped and split into a separate task.
3. Move one boundary at a time. A Flutter feature or backend module is not
   moved until its direct imports and focused tests can be updated together.
4. Preserve public symbols, HTTP paths, database table names, Riverpod provider
   names, and GoRouter paths. Directory names are not an API-change mechanism.
5. Update test file locations after the production files they cover, then run
   the focused test group before moving to the next boundary.
6. Keep generated Drift output out of hand-edited moves; regenerate it only if
   generated import paths require it.
7. `docs/` is intentionally ignored for agent workspace artifacts. Keep that
   ignore rule and stage only the approved review or design files with
   `git add -f`; never add the entire ignored documentation tree.

## Delivery Sequence

1. Record a clean baseline for tracked files and keep `logcat.txt` outside the
   commit. Create `docs/reviews/`, move the review artifact, and remove the
   root debug log.
2. Establish Flutter `app`, `data`, and `shared` boundaries, moving the router,
   theme, local database, remote API services, and generic widgets without
   changing their behavior.
3. Move Flutter feature folders one domain at a time, beginning with isolated
   domains (`auth`, `dashboard`, `welcome`) and then catalog, booking, trips,
   profile, partner, and search. Move matching tests with each domain.
4. Establish backend `core` and `infrastructure`, then move backend code one
   module at a time while keeping existing endpoint registration intact.
5. Move backend tests by module, remove stale path references, and verify the
   final tree has no duplicate active source files or temporary root artifacts.

Each delivery step is a separate commit. The application must build and pass
the relevant checks before the next commit starts.

## Error Handling and Compatibility

This reorganization deliberately preserves existing error classes, status-code
mapping, retry behavior, cache fallback behavior, authentication redirects, and
Socket.IO room lifecycle. A failed import update, generated-code mismatch, or
route-registration problem is fixed in the same structural step; it is not
masked with a duplicate compatibility implementation.

## Verification

After each Flutter step, run the focused tests for the moved boundary followed
by:

```powershell
flutter analyze
flutter test
git diff --check
```

After each backend step, run the focused Vitest files followed by:

```powershell
npm run db:validate
npm run build
npm test
```

Run the backend commands from `backend/`. Before the final commit, verify the
application still supports login/logout, bootstrap with cached offline data,
auth refresh, booking handoff, route back-navigation, and Socket.IO reconnect
using the existing manual verification flow.

## Acceptance Criteria

- A new contributor can locate a Flutter feature, its state, its UI, and its
  tests without searching across unrelated top-level technical-layer folders.
- A backend endpoint's route, controller, validation, persistence, and tests
  are located under one module or an explicitly documented shared boundary.
- `android`, `ios`, `web`, `windows`, package configuration, API paths,
  database schema, and runtime behavior remain unchanged.
- No duplicate active implementation remains after a move.
- All Flutter and backend validation commands pass, and `git diff --check`
  reports no whitespace errors.
