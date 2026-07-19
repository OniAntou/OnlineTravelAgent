# Admin booking operations (minimal) design

**Status:** Approved for planning

## Goal

Make the existing Admin booking page easier to demonstrate and operate without
turning it into a full back-office system. An Admin can immediately see how many
bookings still need attention, filter them by state, and confirm or cancel a
booking from the existing detail modal.

## Scope

### 1. Booking status

Add `PENDING` to the persisted `TripStatus` enum. It means the booking was
created but has not yet been confirmed by a successful payment callback or an
Admin. Existing values retain their current meaning:

| Status | Meaning | `isUpcoming` |
| --- | --- | --- |
| `PENDING` | Waiting for confirmation | `true` |
| `ONGOING` | Confirmed, upcoming, or underway | `true` unless its date has passed |
| `COMPLETED` | Finished | `false` |
| `CANCELLED` | Cancelled | `false` |

New bookings start as `PENDING`. A verified VNPay or MoMo callback promotes a
booking to `ONGOING`; it never changes an Admin-cancelled booking. The Admin
status modal adds the explicit `PENDING` choice and retains the existing update
route and Basic Auth protection.

### 2. Admin booking list

Keep the current `/api/admin/trips` response and load-all behaviour; the project
catalogue is small and this avoids a new filtering API. Add a compact status
filter above the existing search input:

- **Tất cả** (default)
- **Chờ xác nhận**
- **Đang diễn ra**
- **Hoàn thành**
- **Đã hủy**

Filtering composes with the existing text search and updates the normal empty
state. Status badges use a distinct, accessible colour and Vietnamese label,
while still rendering the API value safely.

### 3. Dashboard attention card

Extend the existing Admin stats endpoint with `tripsPending`, calculated by a
database count in the same dashboard request. Add one dashboard card labelled
**Đơn chờ xác nhận**. Selecting the card navigates to Booking and activates the
`PENDING` filter. A zero count remains visible as `0`; it is not an error state.

## Data flow

```text
Create booking -> PENDING -> payment verified / Admin confirms -> ONGOING
                     |                  |
                     +-> Admin cancels -+-> CANCELLED

Dashboard PENDING count -> card click -> trip list PENDING filter
```

`TripStatus` changes require a Prisma migration, regenerated Prisma client, and
matching fallback-memory types/data. The schema validation and admin update
input continue to use the generated enum, so `PENDING` is accepted without a
separate string whitelist.

## Error handling and constraints

- Reject invalid status values through the existing Zod validation.
- Preserve the current 401/403 Admin handling and toast errors when the update
  cannot be saved.
- A payment callback only moves a pending booking to ongoing; it must not
  resurrect a cancelled booking.
- No reporting charts, refunds, audit logs, pagination, or customer-facing
  workflow changes are in this scope.

## Verification

- Backend tests cover dashboard pending count, Admin status update, and payment
  confirmation preserving a cancelled booking.
- Flutter/Admin static UI tests cover status labels, filter result/empty state,
  and dashboard-card navigation.
- Run `npm test`, `npm run build`, and `npm run db:validate` from `backend/`,
  then run `flutter analyze` and `flutter test` from the repository root.
