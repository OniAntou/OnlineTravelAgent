# Image Lifecycle Management Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Execute inline task by task. Steps use checkbox syntax for tracking.

**Goal:** Remove no-longer-referenced Supabase catalogue images after successful Admin/Partner updates and deletions without changing CRUD availability.

**Status:** Completed and verified on 2026-07-17.

> Historical scope note (2026-07-18): the later optimization follow-up added
> reference-aware cleanup for abandoned `pending/` uploads. Its current runtime
> contract is documented under `docs/architecture/` and `docs/workflows/`.

**Architecture:** Extend the existing Storage module with strict URL recognition and best-effort deletion. Controllers collect current image references before Prisma writes, then call deletion only after the write/transaction succeeds. Storage failures are logged and ignored by CRUD responses.

**Tech Stack:** Express 5, TypeScript, Prisma 6, Node.js fetch, Supabase Storage REST API, Vitest/Supertest.

---

## File structure

- Modify `backend/src/core/storage/supabase-storage.ts`: parse only this project's public `travel-media` URLs and delete valid object paths through Storage API.
- Modify `backend/src/modules/admin/admin.controller.ts`: collect/reclaim image paths for destination, hotel/rooms, flight, tour and room CRUD.
- Modify `backend/src/modules/partner/partner.controller.ts`: apply identical lifecycle behavior to partner-owned hotel, tour and room data; store `imagePath` on tour creation.
- Modify `backend/tests/core/supabase-storage.test.ts`: strict URL/deletion service coverage.
- Modify `backend/tests/modules/admin/admin-catalog-deletion.test.ts`, `admin-hotel-deletion.test.ts`, `partner-hotel-deletion.test.ts`: controller lifecycle coverage.
- Create `backend/tests/modules/partner/partner-image-lifecycle.test.ts`: update/delete and tour-create coverage.
- Modify architecture/workflow and plan docs to record the completed lifecycle contract.

### Task 1: Add a safe Storage deletion primitive

**Files:**
- Modify: `backend/src/core/storage/supabase-storage.ts`
- Modify: `backend/tests/core/supabase-storage.test.ts`

- [ ] **Step 1: Write failing deletion tests**

```ts
await deleteManagedPublicImages([
  "https://project.supabase.co/storage/v1/object/public/travel-media/catalog/old.png",
  "assets/images/legacy.png",
]);
expect(fetchMock).toHaveBeenCalledWith(
  "https://project.supabase.co/storage/v1/object/travel-media",
  expect.objectContaining({ method: "DELETE", body: JSON.stringify({ prefixes: ["catalog/old.png"] }) }),
);
```

Add cases proving a different host, bucket, private endpoint, malformed URL and empty value trigger no fetch; add a failed delete response case that resolves without throwing.

- [ ] **Step 2: Confirm failure**

Run: `npm test -- --run tests/core/supabase-storage.test.ts`

Expected: FAIL because `deleteManagedPublicImages` does not exist.

- [ ] **Step 3: Implement strict parsing and best-effort deletion**

```ts
export async function deleteManagedPublicImages(values: readonly string[]): Promise<void> {
  const { baseUrl, serviceKey, bucket } = readStorageConfig();
  const prefixes = [...new Set(values.flatMap((value) => parseManagedPublicObjectKey(value, baseUrl, bucket) ?? []))];
  if (!prefixes.length) return;
  try {
    const response = await fetch(`${baseUrl}/storage/v1/object/${encodeURIComponent(bucket)}`, {
      method: "DELETE",
      headers: { apikey: serviceKey, authorization: `Bearer ${serviceKey}`, "content-type": "application/json" },
      body: JSON.stringify({ prefixes }),
    });
    if (!response.ok) console.warn("Unable to delete replaced catalogue images", { count: prefixes.length });
  } catch {
    console.warn("Unable to delete replaced catalogue images", { count: prefixes.length });
  }
}
```

`parseManagedPublicObjectKey` must require exact `baseUrl`, path prefix `/storage/v1/object/public/<bucket>/`, and a non-empty decoded object key. It must never call Storage for legacy/local/external paths.

- [ ] **Step 4: Run service tests**

Run: `npm test -- --run tests/core/supabase-storage.test.ts`

Expected: PASS.

### Task 2: Reclaim Admin-owned catalogue media

**Files:**
- Modify: `backend/src/modules/admin/admin.controller.ts`
- Modify: `backend/tests/modules/admin/admin-catalog-deletion.test.ts`
- Modify: `backend/tests/modules/admin/admin-hotel-deletion.test.ts`

- [ ] **Step 1: Add failing controller tests**

Mock `deleteManagedPublicImages` and Prisma reads. Cover replacement of a destination/flight/tour/room, deletion of a destination/flight/tour/room, and deletion of a hotel with both `hotel.imagePath` and selected room image paths.

```ts
expect(mocks.deleteManagedPublicImages).toHaveBeenCalledWith([
  oldHotelImage,
  oldRoomImage,
]);
```

- [ ] **Step 2: Confirm targeted tests fail**

Run: `npm test -- --run tests/modules/admin/admin-catalog-deletion.test.ts tests/modules/admin/admin-hotel-deletion.test.ts`

Expected: FAIL because controllers do not read old media or invoke Storage cleanup.

- [ ] **Step 3: Add controller helpers and hook them after persistence**

```ts
function replacedImage(previous: string, next: string | undefined): string[] {
  return next !== undefined && next !== previous ? [previous] : [];
}

// after a successful Prisma update/delete transaction
await deleteManagedPublicImages(pathsToRelease);
```

Read records before mutation using `select` limited to image fields. For hotel deletion, select the hotel image and `rooms: { select: { imagePath: true } }` before the existing transaction. Do not call cleanup when the Prisma write throws.

- [ ] **Step 4: Run Admin lifecycle tests**

Run: `npm test -- --run tests/modules/admin/admin-catalog-deletion.test.ts tests/modules/admin/admin-hotel-deletion.test.ts`

Expected: PASS; tests verify database transaction still completes even when the cleanup mock rejects or resolves a failure signal.

### Task 3: Reclaim Partner-owned catalogue media

**Files:**
- Modify: `backend/src/modules/partner/partner.controller.ts`
- Create: `backend/tests/modules/partner/partner-image-lifecycle.test.ts`
- Modify: `backend/tests/modules/partner/partner-hotel-deletion.test.ts`

- [ ] **Step 1: Write failing Partner tests**

Cover partner hotel/tour/room replacement and deletion, hotel deletion with rooms, ownership failure that skips cleanup, and `POST /api/partner/tours` preserving a supplied `imagePath`.

```ts
expect(mocks.tourCreate).toHaveBeenCalledWith(expect.objectContaining({
  data: expect.objectContaining({ imagePath: uploadedUrl }),
}));
```

- [ ] **Step 2: Confirm failure**

Run: `npm test -- --run tests/modules/partner/partner-image-lifecycle.test.ts tests/modules/partner/partner-hotel-deletion.test.ts`

Expected: FAIL because Partner tour creation always uses the placeholder and no cleanup exists.

- [ ] **Step 3: Implement ownership-safe cleanup**

Read the owned entity first, preserve its image path, update/delete it, then call `deleteManagedPublicImages`. For partner hotel deletion, load rooms with image paths before the transaction. Change `createTour` destructuring and data to use:

```ts
const { name, description, duration, price, imagePath, destinations, includes, departure } = req.body;
imagePath: imagePath || "assets/images/tour_placeholder.jpg",
```

- [ ] **Step 4: Run Partner lifecycle tests**

Run: `npm test -- --run tests/modules/partner/partner-image-lifecycle.test.ts tests/modules/partner/partner-hotel-deletion.test.ts`

Expected: PASS.

### Task 4: Document and verify the full lifecycle

**Files:**
- Modify: `docs/architecture/data-security-and-integrations.md`
- Modify: `docs/workflows/operations-and-release.md`
- Modify: `docs/plans/README.md`
- Modify: `docs/plans/2026-07-17-image-lifecycle-management-design.md`
- Modify: `docs/plans/2026-07-17-image-lifecycle-management-implementation.md`

- [ ] **Step 1: Update documentation**

Document post-commit best-effort deletion, the managed-URL boundary, legacy exclusions, and the remaining abandoned-upload limitation.

- [ ] **Step 2: Run quality gates**

Run from `backend`: `npm run build`, `npm test`, `npm run db:validate`.

Run from repository root: `flutter analyze` and `flutter test test/shared/widgets/app_image_test.dart`.

Expected: all commands pass.

- [ ] **Step 3: Run live smoke test**

Use an authenticated Admin flow to upload image A, save it to a disposable catalogue record, upload image B and update that record, then delete it. Verify Storage retains B only before the record deletion and retains neither after deletion. Remove only the disposable record and test objects.

- [ ] **Step 4: Final safety check**

Run: `git diff --check` and `git status --short`.

Expected: no whitespace errors and no tracked `backend/.env`.

## Self-review

- Coverage: tasks cover strict managed-media recognition, update/delete cleanup, hotel room cascades, Partner tour image persistence, best-effort error behavior, tests, documentation and a live cloud check.
- Scope: no schema migration, gallery UI, scheduled orphan scanner, bucket-policy change or deletion of assets/legacy paths.
- Consistency: only `deleteManagedPublicImages` talks to Storage; every controller invokes it only after its relevant Prisma write succeeds.

## Completion record

- Backend build, 83 Vitest tests, and Prisma schema validation pass.
- Flutter analysis and `test/shared/widgets/app_image_test.dart` pass.
- Live Supabase verification passed with an Admin destination: object A existed after upload, only object B remained after replacement, and neither object remained after deleting the record.
- The temporary destination and its temporary backend process were removed after the check.
