# Trip GPS progress design

## Goal

Help a traveller who is viewing a trip detail screen find their current
position, navigate to the next scheduled stop in the device's maps app, and
confirm their arrival at that stop. GPS is active only while that detail screen
is visible; the application never tracks a user in the background.

## Scope

1. Add foreground-only device location to both place-trip and tour-trip detail
   screens.
2. Show a current-location marker and the distance to the next actionable
   schedule item on the existing OpenStreetMap view.
3. Launch Google Maps on Android and Apple Maps on iOS using the next item's
   latitude and longitude, with a browser-map fallback when neither app can be
   opened.
4. When the device is at most 150 m from that item, offer a confirmation
   action. Confirmation writes `completed` to the existing
   `TripScheduleItem.statusOverride` for the authenticated trip owner, then
   refreshes the schedule UI.

## Boundaries

- Request only foreground location permission: Android precise/coarse location
  and iOS when-in-use location. Do not request background location, start a
  foreground service, persist coordinate history, or send raw device positions
  to the backend.
- A location subscription begins after the detail screen has established that
  GPS is available and permission is granted. It is cancelled in `dispose` and
  when the app becomes inactive; it restarts only if that same screen becomes
  active again.
- GPS is an aid, not proof of attendance. A 150 m proximity signal may show an
  arrival prompt, but only the traveller's explicit confirmation changes the
  schedule status.
- The GPS feature changes only per-trip schedule-item overrides. It does not
  change global templates, trip booking status, catalog coordinates, or admin
  workflow.
- A schedule item without valid coordinates cannot be a GPS target. It remains
  visible in the timeline and no arrival action is offered for it.

## Existing foundation

The Flutter client already uses `flutter_map` and `latlong2`; place and tour
trip detail screens already draw destination/tour markers. `TripScheduleItem`
already exposes nullable `latitude`, `longitude`, and `statusOverride`, while
the backend stores `status_override` on `TripScheduleItem`. Today the client
can only read an owned trip schedule; schedule mutations are admin-only.

## Architecture

### Location boundary

Introduce a small mobile-only `DeviceLocationService` wrapping `geolocator`.
It owns platform capability checks, permission states, current-position stream
configuration, and distance calculation. The service returns typed UI states
instead of exposing plugin exceptions to widgets:

- `ready(position)`
- `serviceDisabled`
- `permissionDenied`
- `permissionDeniedForever`
- `unavailable(message)`

The service uses `LocationAccuracy.high` with a 25 m distance filter. The
screen does not retry in a loop: a user explicitly presses the provided retry
or opens system settings after a denied-forever result.

### Progress target

Flatten schedule days in chronological order, then select the first item that:

1. has finite, valid latitude/longitude values;
2. is not `completed` or `cancelled` after applying the same schedule-status
   resolver used by the timeline; and
3. belongs to the current trip schedule.

This produces one deterministic next GPS target. If no item qualifies, the map
still shows the existing itinerary markers but the GPS card states that there
is no remaining stop to navigate to.

For every new position, calculate metres from the target. At 150 m or less,
show a non-blocking arrival card. Dismissing it suppresses the prompt only for
that target during the current screen session; reopening the screen may show it
again until the traveller confirms or the target changes.

### Navigation handoff

The direction action contains only the target coordinate and an encoded label.
It tries the platform-native URI first and falls back to an HTTPS map URL:

- Android: `google.navigation:q=<lat>,<lng>`.
- iOS: `http://maps.apple.com/?daddr=<lat>,<lng>&dirflg=d`.
- Fallback: `https://www.google.com/maps/dir/?api=1&destination=<lat>,<lng>`.

The app does not calculate turn-by-turn routes, draw road paths, or collect
navigation telemetry.

### Persisted confirmation

Add an authenticated client route for the owner of a trip:

`PATCH /api/trips/:tripId/schedule/items/:itemId/status`

Its body is exactly `{ "statusOverride": "completed" }`. The controller must
verify the trip belongs to `req.userId`, locate the item through that trip's
schedule days, reject all unsupported values, update only `statusOverride`,
emit the existing `schedule_updated` room event, and return the saved item. A
request for another user's trip must not reveal whether its item exists.

The Flutter client performs this request only after the confirmation tap. On a
successful response it invalidates `tripScheduleProvider(tripId)`; on failure
it leaves the item unchanged, surfaces a retryable message, and continues
showing the last GPS position. No raw coordinate is included in this request.

## UI behavior

The shared GPS progress panel belongs directly above the existing map in both
trip detail screens. It has four mutually exclusive states:

| State | User-facing behavior |
| --- | --- |
| Locating | Progress indicator and the next stop's name. |
| Ready | Current-location marker, distance, target name, and `Chỉ đường` button. |
| Within 150 m | Ready content plus `Xác nhận đã đến` and a dismiss action. |
| Unavailable | Clear explanation and a contextual action: retry, open location settings, or no action for missing target coordinates. |

The existing schedule timeline remains the authority for visual status. After
confirmation and provider refresh, its normal `completed` treatment updates
the item. The GPS panel then targets the following unfinished coordinate.

## Error handling and privacy

- GPS service disabled: explain how to turn on Location and offer retry.
- Permission denied: explain that location is needed only while this screen is
  open and allow the user to continue using the map without GPS.
- Permission permanently denied: offer an explicit button to open app settings.
- Position stream error, timeout, invalid coordinate, or unavailable map app:
  keep the detail screen usable and show a recoverable message.
- Missing network does not stop local distance calculation. It can prevent the
  status confirmation request; the user may retry after connectivity returns.
- Device positions stay in process memory and are discarded when the stream is
  cancelled. They must not enter Drift, logs, analytics, Socket.IO events, or
  API payloads.

## Validation

- Unit tests cover coordinate validation, ordering/selection of the next stop,
  distance threshold behavior, prompt suppression, and platform map URI
  generation.
- Service tests use a mocked location gateway for every permission and service
  state, and assert subscriptions are cancelled.
- Widget tests cover ready, denied, no-coordinate, within-radius, confirmation
  success, and confirmation failure states.
- Backend tests cover owner authorization, cross-user non-disclosure, input
  validation, database update, and `schedule_updated` emission.
- Run `flutter analyze`, focused Flutter tests, backend tests/build, Prisma
  validation, and a device/emulator smoke check that grants then revokes
  location permission while a trip detail screen is open.

## Non-goals

- Background tracking, geofencing, staff/group location sharing, or route
  recording.
- Automatic completion based solely on GPS.
- Road routing or replacing the existing OpenStreetMap presentation.
- Retrofitting coordinates for existing schedule data.
