# Trip change requests (minimal) design

**Status:** Approved for planning

## Goal

Replace the customer-facing instant-cancellation action with a small, auditable
request workflow. A customer can ask to reschedule a future trip or receive a
simulated refund; an Admin then approves or rejects the request and the trip
changes only after approval.

## Scope

### 1. Persisted request record

Create a dedicated `TripChangeRequest` record rather than adding transient
refund fields to `Trip`. It preserves why a customer made the request, its
decision, and the simulated refund amount without overwriting the trip's
original payment history.

```text
TripChangeRequestType:   RESCHEDULE | REFUND
TripChangeRequestStatus: PENDING | APPROVED | REJECTED
```

Each record belongs to one `Trip` and contains:

- `reason` — the customer's required explanation;
- `requestedDate` — required only for `RESCHEDULE`, using the same display
  date format already stored by `Trip.date`;
- `refundAmount` — set by an Admin only when approving `REFUND`;
- `adminNote` and `reviewedAt` — visible to the customer after a decision;
- normal creation/update timestamps.

The new schema includes indices for a trip's requests and for the Admin's
status queue. The Prisma migration and the fallback-memory database must both
represent the same states.

### 2. Customer request flow

Only the owner of a future `PENDING` or `ONGOING` trip may create a request.
The customer can have one `PENDING` change request per trip, regardless of
type. A completed or already-cancelled trip cannot receive a request.

The existing **Hủy vé** action is replaced by two explicit actions:

- **Đổi lịch** opens a date picker and reason form;
- **Yêu cầu hoàn tiền** opens a reason form.

The application sends the request to the server; it does not cancel the trip
or calculate a refund locally. The trip-detail screen shows the latest request
as a compact status card, including requested date, customer reason, Admin
note, and refund amount when present. While a request is pending, both actions
are disabled and the card explains that it is awaiting review.

### 3. Admin review flow

Add a compact **Yêu cầu thay đổi** section beside the existing Admin booking
management view. It loads requests, defaults to the pending queue, and can be
filtered by status. For each request the Admin can inspect trip/customer
context and choose **Duyệt** or **Từ chối**.

On approval:

| Request type | Trip change | Request change |
| --- | --- | --- |
| `RESCHEDULE` | Replace `Trip.date` with `requestedDate`; keep the existing active trip status and `isUpcoming = true`. | `APPROVED`, review metadata saved. |
| `REFUND` | Set `Trip.status = CANCELLED` and `isUpcoming = false`. The original payment transaction/status is retained. | `APPROVED`, review metadata and Admin-entered refund amount saved. |

On rejection, the trip remains unchanged and the request becomes `REJECTED`.
The Admin can add an optional note for either decision. A reviewed request is
immutable: it cannot be approved or rejected a second time.

This is a coursework simulation only. It records a refund amount but never
calls VNPay, MoMo, or any other payment-provider refund endpoint.

### 4. API boundary

Customer routes, protected by the existing client authentication and ownership
checks:

```text
GET  /api/trips/:id/change-requests
POST /api/trips/:id/change-requests
```

The create body is:

```json
{
  "type": "RESCHEDULE | REFUND",
  "reason": "string (required)",
  "requestedDate": "required for RESCHEDULE"
}
```

Admin routes remain behind the existing Admin authentication:

```text
GET   /api/admin/trip-change-requests?status=PENDING
PATCH /api/admin/trip-change-requests/:id
```

The Admin decision body contains `decision` (`APPROVED` or `REJECTED`), an
optional `adminNote`, and a required non-negative `refundAmount` only when
approving a refund. If the trip has a total price, the amount cannot exceed it.

The old customer `POST /api/trips/:id/cancel` route and its Flutter service
method are removed so the browser or a stale client cannot bypass the review
workflow. Admins retain their existing direct booking-status control.

## Data flow

```text
Customer request -> PENDING -> Admin approves -> RESCHEDULE: trip date changes
                                  |             REFUND: trip becomes CANCELLED
                                  +-> Admin rejects -> trip unchanged
```

The create and review service operations use a transaction. Creation checks
ownership, trip eligibility, and the absence of a pending request. Review
checks that the request is still pending, validates the decision data, updates
the request, and applies the related trip update atomically.

## Validation and error handling

- Require a trimmed reason of 5–500 characters.
- Require a valid future requested date for `RESCHEDULE`; reject the field for
  `REFUND`.
- Return `409 Conflict` if a pending request already exists for that trip or an
  Admin attempts to review a request that another decision has already closed.
- Return `404` for a missing request/trip or a trip not owned by the client.
- Return `400` for malformed input and an invalid simulated refund amount.
- Surface server messages as normal Flutter/Admin error feedback and leave the
  currently displayed trip untouched on failure.

## Out of scope

- Real payment-provider refunds, wallet credit, or accounting reconciliation.
- Automatic approvals, refund-policy calculations, cancellation fees, or
  notifications.
- A separate customer history screen, pagination, or a complex back-office
  workflow.

## Verification

- Backend tests cover ownership, one-pending-request enforcement, reschedule
  approval, refund approval, rejection, invalid dates/amounts, and immutable
  reviewed requests.
- Flutter tests cover the two request actions, disabled pending state, and
  decision details shown in the trip-detail card.
- Admin UI tests cover queue filtering and the approve/reject dialogs.
- Run `npm test`, `npm run build`, and `npm run db:validate` from `backend/`,
  then run `flutter analyze` and `flutter test` from the repository root.
