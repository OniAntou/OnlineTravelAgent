# Welcome on Every Launch Design

**Status:** Approved

## Goal

Always show the Welcome screen first when the Flutter application starts or is reopened, whether a previously authenticated session is restored or not.

## Behavior

1. `GoRouter` continues to start at `AppRoutes.welcome` (`/`).
2. Restoring a saved token updates authentication state, but does not redirect a user away from Welcome.
3. The existing Welcome Explore action continues to navigate to `AppRoutes.main`.
4. A successful login or registration continues to navigate to the requested protected route when `from` is supplied, otherwise to Main.
5. Partner Dashboard remains protected: an unauthenticated request redirects to Login with the original destination in `from`.

## Implementation boundary

Remove only the logged-in-Welcome redirect from `lib/core/router/app_router.dart`:

```dart
if (authState.isLoggedIn && location == AppRoutes.welcome) {
  return AppRoutes.main;
}
```

Do not add a persisted onboarding flag, alter token storage, change Welcome visuals, or relax Partner Dashboard authorization.

## Expected flow

```text
App launch -> Welcome -> session restoration completes -> Welcome remains visible
                                      |
                                      +-> user taps Explore -> Main
```

## Verification

- Start the app with a saved token and confirm Welcome remains visible after session restoration.
- Tap Explore and confirm navigation reaches Main.
- Open Partner Dashboard while logged out and confirm Login still receives a `from` destination.
- Run `flutter analyze` and focused router tests if present.
