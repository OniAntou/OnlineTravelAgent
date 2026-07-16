# Safe Dependency Upgrades Implementation Plan

> **For agentic workers:** Execute the checked tasks inline and verify each package-manager surface before publishing.

**Goal:** Update only compatible patch/minor dependencies and remove the obsolete Flutter SQLite support package without changing application behavior.

**Architecture:** The backend stays on Prisma 6 and TypeScript 5, while Flutter stays on the current major versions of routing, secure storage, connectivity, and geolocation packages. Version resolution is delegated to npm and Pub so lockfiles remain the source of reproducible installs.

**Tech Stack:** Node 24, npm 11, Express, Prisma 6, Flutter 3.44, Dart 3.12, Drift.

---

### Task 1: Update safe backend packages

**Files:**
- Modify: `backend/package-lock.json`
- Verify: `backend/package.json`, `backend/package-lock.json`

- [x] Run `npm update helmet tsx vitest @types/multer @types/node @types/supertest` from `backend`.
- [x] Preserve the existing Prisma 6 and TypeScript 5 major versions.
- [x] Verify a Linux-compatible clean install with `npm ci --ignore-scripts --os=linux --cpu=x64`, then restore the local Windows install with `npm ci`.

### Task 2: Remove obsolete Flutter SQLite support

**Files:**
- Modify: `pubspec.yaml`
- Modify: `pubspec.lock`

- [x] Remove this obsolete direct dependency:

```yaml
  sqlite3_flutter_libs: ^0.5.0
```

- [x] Run `flutter pub upgrade` to update only versions permitted by existing constraints. Do not use `--major-versions`.

### Task 3: Verify build and test surfaces

**Files:**
- Verify: `backend/src/**`, `backend/prisma/schema.prisma`, `lib/**`, `test/**`

- [x] From `backend`, run `npm run db:generate`, `npm run db:validate`, `npm run build`, and `npm test`.
- [x] From the repository root, run `flutter analyze` and `flutter test`.
- [x] Inspect `git diff --check` and the dependency diffs. Keep no upgrades to Prisma 7, TypeScript 7, go_router 17, flutter_secure_storage 10, connectivity_plus 7, or latlong2 0.10 in this change.
