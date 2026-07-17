# Mobile performance design

## Goal

Reduce user-visible network and rendering cost without adding distributed
infrastructure or changing existing upload/API form contracts.

## Scope

1. Convert uploaded JPEG and PNG files to bounded WebP before writing them to
   Supabase Storage. The longest edge is 1600 px and quality is 82. GIF files
   remain unchanged so animation is preserved.
2. Replace the search provider's non-cancellable delayed future with a
   state-owned timer. Only the settled query is sent to the API.
3. Replace Partner dashboard `picsum.photos` placeholders with each hotel's or
   tour's existing `imagePath`, rendered through the shared image widget.

## Boundaries

- The upload response remains `{ url }`; callers do not change.
- The backend remains single-instance; no Redis or new external service.
- Existing managed images are not retroactively rewritten.
- Invalid image input still fails with the existing safe upload error.

## Validation

- Unit-test image conversion and the GIF preservation path.
- Unit-test debounce behavior where practical, then run Flutter analysis/tests.
- Run backend build, tests, schema validation, and whitespace checks.
