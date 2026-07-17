# Partner Management Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox syntax for tracking.

**Goal:** Add a complete Admin Partner management surface backed by the existing User.role = PARTNER model.

**Architecture:** Keep User as the sole account model. Add bounded Admin Partner endpoints and a shared cleanup helper that removes Partner catalog data before role/account changes. Extend the static Admin panel with a dedicated Partner page; no Prisma migration is required.

**Tech Stack:** Express 5, Prisma/PostgreSQL, Zod, Vitest/Supertest, Supabase Storage, static HTML/JavaScript.

---

### Task 1: Create the failing Partner API and panel tests

**Files:**
- Create: backend/tests/modules/admin/admin-partner-management.test.ts
- Modify: backend/tests/core/admin-panel-origin.test.ts
- Reference: backend/tests/modules/admin/admin-user-deletion.test.ts
- Reference: backend/tests/modules/admin/admin-catalog-deletion.test.ts

- [ ] **Step 1: Add the API contract tests.**

Create hoisted Prisma and Storage mocks following admin-catalog-deletion.test.ts. Send Basic Auth requests for GET/POST /api/admin/partners, POST /api/admin/users/user-1/promote-partner, POST /api/admin/partners/partner-1/demote, and DELETE /api/admin/partners/partner-1.

The tests must assert these calls:

~~~
expect(mocks.userFindMany).toHaveBeenCalledWith(expect.objectContaining({
  where: { role: 'PARTNER' },
}));
expect(mocks.userCreate).toHaveBeenCalledWith(expect.objectContaining({
  data: expect.objectContaining({ role: 'PARTNER' }),
}));
expect(mocks.userUpdate).toHaveBeenCalledWith({
  where: { id: 'user-1' }, data: { role: 'PARTNER' },
});
expect(mocks.transaction).toHaveBeenCalledBefore(media.deleteManagedPublicImages as any);
~~~

- [ ] **Step 2: Verify the tests are red.**

Run:

~~~powershell
npx vitest run tests/modules/admin/admin-partner-management.test.ts
~~~

Expected: FAIL because Partner Admin routes do not exist.

- [ ] **Step 3: Add a static panel contract.**

Extend admin-panel-origin.test.ts so GET /admin/ must contain id="nav-partners", id="page-partners", and id="modal-partner".

- [ ] **Step 4: Verify the panel contract is red.**

Run:

~~~powershell
npx vitest run tests/core/admin-panel-origin.test.ts
~~~

Expected: FAIL on the Partner markup ids.

- [ ] **Step 5: Keep the red tests uncommitted until the feature is green.**

Do not commit failing routes or markup to `main`. Carry both test files into Task 2 and Task 3, then commit each completed green vertical slice.

### Task 2: Implement the Admin Partner API and cleanup lifecycle

**Files:**
- Modify: backend/src/modules/admin/admin.schema.ts
- Modify: backend/src/modules/admin/admin.routes.ts
- Modify: backend/src/modules/admin/admin.controller.ts
- Modify: backend/src/core/types/index.ts
- Test: backend/tests/modules/admin/admin-partner-management.test.ts

- [ ] **Step 1: Add exact schemas and types.**

Add these schemas to admin.schema.ts and matching CreatePartnerBody/UpdatePartnerBody interfaces to core/types/index.ts:

~~~ts
export const adminPartnerCreateSchema = adminUserSchema;
export const adminPartnerUpdateSchema = z.object({
  name: z.string().min(1, 'name is required'),
  email: z.string().email('invalid email'),
  password: z.string().min(6, 'password must be at least 6 characters').optional(),
});
~~~

- [ ] **Step 2: Register the six protected routes.**

Append after User routes in admin.routes.ts:

~~~ts
adminRouter.get('/partners', adminController.getPartners);
adminRouter.post('/partners', validate(adminPartnerCreateSchema), adminController.createPartner);
adminRouter.put('/partners/:id', validate(adminPartnerUpdateSchema), adminController.updatePartner);
adminRouter.post('/users/:id/promote-partner', adminController.promoteUserToPartner);
adminRouter.post('/partners/:id/demote', adminController.demotePartner);
adminRouter.delete('/partners/:id', adminController.deletePartner);
~~~

- [ ] **Step 3: Implement one removePartnerCatalog helper.**

In admin.controller.ts, load only a PARTNER and select hotel ids/images/nested room images plus tour ids/images. Throw HttpError(404, 'Partner not found') when absent. Build hotelIds, tourIds and flattened imagePaths, then execute:

~~~ts
await prisma.$transaction(async (tx) => {
  await tx.scheduleTemplate.deleteMany({ where: { tourPackageId: { in: tourIds } } });
  await tx.review.deleteMany({ where: { OR: [
    { targetType: ReviewTargetType.hotel, targetId: { in: hotelIds } },
    { targetType: ReviewTargetType.tour, targetId: { in: tourIds } },
  ] } });
  await tx.room.deleteMany({ where: { hotelId: { in: hotelIds } } });
  await tx.hotel.deleteMany({ where: { id: { in: hotelIds } } });
  await tx.tourPackage.deleteMany({ where: { id: { in: tourIds } } });
});
await deleteManagedPublicImages(imagePaths);
~~~

Storage cleanup must remain after the database transaction.

- [ ] **Step 4: Implement API behavior.**

getPartners queries role PARTNER and selects id, name, email, createdAt, _count.hotels, and _count.tours. createPartner hashes password and fixes role to PARTNER. updatePartner requires Partner role and includes a hashed password only when supplied. promoteUserToPartner requires role USER, returns 409 when already Partner, and changes role to Partner. demotePartner invokes cleanup then sets role to USER. deletePartner invokes cleanup, deletes user reviews, then deletes User so Prisma cascades trips, documents, favorites and refresh tokens. Change getUsers to role USER so lists never duplicate accounts.

- [ ] **Step 5: Run focused green tests.**

Run:

~~~powershell
npx vitest run tests/modules/admin/admin-partner-management.test.ts tests/modules/admin/admin-user-deletion.test.ts tests/modules/admin/admin-catalog-deletion.test.ts
~~~

Expected: PASS.

- [ ] **Step 6: Commit the backend implementation.**

~~~powershell
git add backend/src/modules/admin/admin.schema.ts backend/src/modules/admin/admin.routes.ts backend/src/modules/admin/admin.controller.ts backend/src/core/types/index.ts backend/tests/modules/admin/admin-partner-management.test.ts
git commit -m "feat: manage partners from admin"
~~~

### Task 3: Build the Partner Admin UI

**Files:**
- Modify: backend/admin/index.html
- Test: backend/tests/core/admin-panel-origin.test.ts

- [ ] **Step 1: Add Partner markup.**

Add nav-partners beside Users, page-partners with tb-partners and empty-partners, and modal-partner with hidden id, name, email and password fields. The password label must say blank preserves the current password while editing.

- [ ] **Step 2: Add data flow and rendering.**

Extend the current state and dispatcher:

~~~js
let data={destinations:[],hotels:[],flights:[],tours:[],trips:[],categories:[],users:[],partners:[],documents:[]};
const loaders={
  dashboard:loadDashboard, destinations:loadDestinations, hotels:loadHotels,
  flights:loadFlights, tours:loadTours, trips:loadTrips,
  categories:loadCategories, users:loadUsers, partners:loadPartners, documents:loadDocuments,
};
~~~

Implement loadPartners for GET /api/admin/partners. Render escaped name/email, _count.hotels, _count.tours, plus edit/demote/delete actions. Add the Partner title and make openAddModal open the Partner form on this page.

- [ ] **Step 3: Add lifecycle controls.**

Implement openPartnerModal, savePartner, promoteUser, confirmDemotePartner, and confirmDeletePartner. POST for new Partners; PUT for existing ones; omit a blank edit password. Add the promotion action to User rows. Both destructive confirmations must state that owned hotels, rooms and tours will be deleted.

- [ ] **Step 4: Keep lists consistent.**

After every create, edit, promote, demote or delete, run:

~~~js
await Promise.all([loadUsers(), loadPartners()]);
~~~

before rendering the current page.

- [ ] **Step 5: Verify UI behavior.**

Run:

~~~powershell
npx vitest run tests/core/admin-panel-origin.test.ts
~~~

Start a temporary backend on an unused port and use agent-browser to verify the nav item, empty state and Partner modal. Stop only that temporary server.

- [ ] **Step 6: Commit the panel.**

~~~powershell
git add backend/admin/index.html backend/tests/core/admin-panel-origin.test.ts
git commit -m "feat: add partner administration panel"
~~~

### Task 4: Update documents and verify release readiness

**Files:**
- Modify: docs/architecture/backend-and-api.md
- Modify: docs/workflows/product-journeys.md
- Create: docs/plans/2026-07-17-partner-management-implementation.md

- [ ] **Step 1: Document the completed API and journey.**

Add the six Admin Partner routes, role boundaries, counts and transaction-then-Storage deletion order to backend-and-api.md. Add Partner creation, promotion, edit, demotion and deletion to the Admin workflow in product-journeys.md.

- [ ] **Step 2: Run full verification.**

Run from backend:

~~~powershell
npm run build
npm test
npm run db:validate
npm audit --omit=dev --audit-level=high
~~~

Run from repository root:

~~~powershell
flutter analyze
flutter test
git diff --check
~~~

Expected: all commands pass. Do not run db:generate because no Prisma schema change is planned.

- [ ] **Step 3: Review and commit documentation.**

Run:

~~~powershell
git status -sb
git diff --stat HEAD~3..HEAD
~~~

Confirm only Partner implementation, tests and documentation are present, then commit:

~~~powershell
git add docs/architecture/backend-and-api.md docs/workflows/product-journeys.md docs/plans/2026-07-17-partner-management-implementation.md
git commit -m "docs: describe partner administration workflow"
~~~

Do not push until the user explicitly asks for publication.
