# Supabase Storage Images Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Execute this plan inline, task by task. Steps use checkbox syntax for tracking.

**Goal:** Store images uploaded by Admin and Partner in shared Supabase Storage and return public HTTPS URLs without exposing privileged credentials.

**Architecture:** Existing authenticated upload routes remain the public contract. Multer accepts one validated image in memory; a small Storage service uploads it using the backend-only service-role key and returns the public URL. Admin, Partner, and Flutter consume that absolute URL.

**Tech Stack:** Node.js 24 `fetch`, Express 5, Multer 2, Vitest/Supertest, Supabase Storage, static HTML panels, Flutter.

**Status:** Complete. Source, bucket configuration, unit/API tests, build, Prisma validation, Flutter regression checks and a live Admin upload/public-read/delete smoke test have passed. The service-role key remains only in ignored `backend/.env`.

---

## File structure

- Create `backend/src/core/storage/supabase-storage.ts`: Storage configuration, upload request, public URL construction.
- Create `backend/src/core/http/image-upload-handler.ts`: one Express handler shared by Admin and Partner.
- Modify `backend/src/core/middleware/upload.ts`: image-only, 10 MB, memory-backed Multer.
- Modify `backend/src/modules/admin/admin.routes.ts` and `backend/src/modules/partner/partner.routes.ts`: mount the shared handler.
- Modify `backend/admin/index.html` and `backend/partner/index.html`: resolve absolute and legacy relative image URLs.
- Modify `backend/.env.example`, architecture/workflow docs, and upload tests.

### Task 1: Create the Storage boundary

**Files:**
- Create: `backend/src/core/storage/supabase-storage.ts`
- Create: `backend/tests/core/supabase-storage.test.ts`
- Modify: `backend/.env.example`

- [ ] **Step 1: Write a failing service test**

```ts
vi.stubEnv("SUPABASE_URL", "https://project.supabase.co");
vi.stubEnv("SUPABASE_SERVICE_ROLE_KEY", "service-secret");
vi.stubEnv("SUPABASE_STORAGE_BUCKET", "travel-media");
vi.spyOn(globalThis, "fetch").mockResolvedValue(new Response("{}", { status: 200 }));

await expect(uploadPublicImage(file)).resolves.toMatch(
  /^https:\/\/project\.supabase\.co\/storage\/v1\/object\/public\/travel-media\/catalog\/.+\.png$/,
);
```

- [ ] **Step 2: Confirm failure**

Run: `npm test -- --run tests/core/supabase-storage.test.ts`

Expected: FAIL because the service does not yet exist.

- [ ] **Step 3: Implement the service**

```ts
export async function uploadPublicImage(file: Express.Multer.File): Promise<string> {
  const { baseUrl, serviceKey, bucket } = readStorageConfig();
  const extension = getSafeImageExtension(file);
  if (!extension) throw new HttpError(400, "File type not allowed");
  const objectKey = `catalog/${crypto.randomUUID()}${extension}`;
  const response = await fetch(`${baseUrl}/storage/v1/object/${encodeURIComponent(bucket)}/${objectKey}`, {
    method: "POST",
    headers: { apikey: serviceKey, authorization: `Bearer ${serviceKey}`, "content-type": file.mimetype, "x-upsert": "false" },
    body: file.buffer,
  });
  if (!response.ok) throw new HttpError(502, "Image upload failed");
  return `${baseUrl}/storage/v1/object/public/${encodeURIComponent(bucket)}/${objectKey}`;
}
```

`readStorageConfig` must return `HttpError(503, "Image storage is not configured")` for missing or invalid configuration without including secret or upstream details.

- [ ] **Step 4: Document variables**

```dotenv
SUPABASE_URL="https://your-project.supabase.co"
SUPABASE_SERVICE_ROLE_KEY="your-supabase-service-role-key"
SUPABASE_STORAGE_BUCKET="travel-media"
```

- [ ] **Step 5: Run the service test**

Run: `npm test -- --run tests/core/supabase-storage.test.ts`

Expected: PASS.

### Task 2: Use Storage from the two protected API routes

**Files:**
- Create: `backend/src/core/http/image-upload-handler.ts`
- Modify: `backend/src/core/middleware/upload.ts`
- Modify: `backend/src/modules/admin/admin.routes.ts`
- Modify: `backend/src/modules/partner/partner.routes.ts`
- Modify: `backend/tests/core/upload.test.ts`

- [ ] **Step 1: Extend route tests before code**

```ts
vi.mock("../../src/core/storage/supabase-storage.js", () => ({
  uploadPublicImage: vi.fn().mockResolvedValue("https://project.supabase.co/storage/v1/object/public/travel-media/catalog/cover.png"),
}));

const res = await request(app).post("/api/admin/upload").set("Authorization", adminAuth)
  .attach("file", Buffer.from("png"), { filename: "cover.png", contentType: "image/png" });
expect(res.body).toEqual({ url: "https://project.supabase.co/storage/v1/object/public/travel-media/catalog/cover.png" });
```

Add a Partner JWT case and preserve the no-file and unsupported-file checks.

- [ ] **Step 2: Confirm failure**

Run: `npm test -- --run tests/core/upload.test.ts`

Expected: FAIL because the current route returns a local `/uploads/...` path.

- [ ] **Step 3: Switch Multer to image-only memory storage**

```ts
export const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 10 * 1024 * 1024, files: 1, fields: 20, fieldNameSize: 100 },
  fileFilter: (_req, file, cb) => cb(null, getSafeImageExtension(file) !== null),
});
```

Keep `UPLOAD_DIR` only for read-only legacy `/uploads/...` compatibility. Preserve the existing `UploadValidationError` response for rejected files.

- [ ] **Step 4: Add and mount the shared asynchronous handler**

```ts
export const imageUploadHandler = asyncHandler(async (req, res) => {
  if (!req.file) return void res.status(400).json({ error: "No file uploaded" });
  res.json({ url: await uploadPublicImage(req.file) });
});
```

Replace each inline callback with `upload.single("file"), imageUploadHandler`. Keep the existing Admin Basic Auth and Partner JWT middleware order unchanged.

- [ ] **Step 5: Run route tests**

Run: `npm test -- --run tests/core/upload.test.ts`

Expected: PASS.

### Task 3: Fix Admin and Partner URL previews

**Files:**
- Modify: `backend/admin/index.html`
- Modify: `backend/partner/index.html`

- [ ] **Step 1: Add a shared-in-file URL resolver to both panels**

```js
function resolveImageUrl(url) {
  return /^https?:\/\//i.test(url) ? url : API + url;
}
```

- [ ] **Step 2: Use it for both upload and edit previews**

```js
imgEl.src = resolveImageUrl(json.url);
img.src = resolveImageUrl(url);
```

- [ ] **Step 3: Verify no unsafe concatenation remains**

Run: `rg -n "API \+ json\.url|img\.src = API \+ url" backend/admin/index.html backend/partner/index.html`

Expected: no matches.

### Task 4: Provision and document Supabase Storage

**Files:**
- Modify locally only: `backend/.env` (ignored; never stage)
- Modify: `docs/architecture/data-security-and-integrations.md`
- Modify: `docs/workflows/operations-and-release.md`

- [ ] **Step 1: Verify current official Storage guidance and project state**

Check the official Supabase documentation and project tooling before mutation. Do not print or store any key in tracked files.

- [ ] **Step 2: Create the bucket**

Create public `travel-media` with a 10 MB object limit and MIME types `image/jpeg`, `image/png`, `image/gif`, `image/webp`. Do not create upload/delete policies for `anon` or `authenticated`.

- [ ] **Step 3: Configure the local backend**

Set the three documented variables in ignored `backend/.env`. The service-role key is backend-only and must not enter Flutter, Admin/Partner HTML, Git, terminal output, or screenshots.

- [ ] **Step 4: Document the operating contract**

Record that PostgreSQL holds URLs, Storage holds media, every backend runner needs the Storage variables, and public read access does not permit public upload.

- [ ] **Step 5: Verify one real object**

Upload a small PNG through the authenticated Admin API, GET the returned public URL without credentials, then delete only that verification object through trusted server/project tooling.

### Task 5: Regression verification and closeout

**Files:**
- Modify: `docs/plans/README.md`
- Modify: `docs/plans/2026-07-17-supabase-storage-images-design.md`
- Modify: `docs/plans/2026-07-17-supabase-storage-images-implementation.md`

- [ ] **Step 1: Run backend gates**

Run from `backend`: `npm run build` then `npm test`.

Expected: build succeeds and all Vitest tests pass.

- [ ] **Step 2: Run Flutter regression checks**

Run from repo root: `flutter test test/shared/widgets/app_image_test.dart` then `flutter analyze`.

Expected: HTTPS remains a `NetworkImage` and analysis has no issues.

- [ ] **Step 3: Mark plan/spec implemented only after real upload succeeds**

Update status and link the plan from `docs/plans/README.md`.

- [ ] **Step 4: Check staged scope before any user-requested publish**

Run: `git diff --check` and `git status --short`.

Expected: no whitespace errors and no `backend/.env` changes. Commit only if the user explicitly asks.

## Self-review

- Coverage: the tasks implement the bucket, backend-only credential, image validation, unchanged JSON contract, panel previews, old `/uploads` compatibility, documentation, and a real Storage verification.
- Exclusions: no database migration, asset-seed migration, backend deployment, asset garbage collection, or client-side Supabase key.
- Consistency: both routes call `imageUploadHandler`, which calls only `uploadPublicImage`; only the Storage service constructs public URLs.
