# Welcome on Every Launch Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Keep the Welcome screen visible at application launch even after a saved authenticated session is restored.

**Architecture:** Move the router redirect decision into a small pure top-level function so it can be tested without secure storage or widget setup. Make GoRouter's Welcome initial location override the platform route restored by Android, call the resolver from the existing redirect callback, and intentionally omit the logged-in-Welcome redirect while preserving login/register and Partner Dashboard rules.

**Tech Stack:** Flutter, Dart, GoRouter 16, Riverpod, flutter_test.

---

### Task 1: Lock the desired redirect contract with a focused unit test

**Files:**
- Create: `test/core/router/app_router_test.dart`
- Modify: `lib/core/router/app_router.dart`

- [x] **Step 1: Create the failing redirect test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:online_travel_agent/core/router/app_router.dart';
import 'package:online_travel_agent/core/router/app_routes.dart';

void main() {
  group('resolveAppRedirect', () {
    test('keeps Welcome visible after a logged-in session is restored', () {
      expect(
        resolveAppRedirect(
          isLoggedIn: true,
          location: AppRoutes.welcome,
          queryParameters: const {},
        ),
        isNull,
      );
    });

    test('keeps Welcome visible for a logged-out user', () {
      expect(
        resolveAppRedirect(
          isLoggedIn: false,
          location: AppRoutes.welcome,
          queryParameters: const {},
        ),
        isNull,
      );
    });

    test('sends an anonymous Partner Dashboard request to Login', () {
      expect(
        resolveAppRedirect(
          isLoggedIn: false,
          location: AppRoutes.partnerDashboard,
          queryParameters: const {},
        ),
        '${AppRoutes.login}?from=${Uri.encodeComponent(AppRoutes.partnerDashboard)}',
      );
    });

    test('returns a logged-in Login request to its original destination', () {
      expect(
        resolveAppRedirect(
          isLoggedIn: true,
          location: AppRoutes.login,
          queryParameters: const {'from': AppRoutes.partnerDashboard},
        ),
        AppRoutes.partnerDashboard,
      );
    });

    test('sends a logged-in Login request without from to Main', () {
      expect(
        resolveAppRedirect(
          isLoggedIn: true,
          location: AppRoutes.login,
          queryParameters: const {},
        ),
        AppRoutes.main,
      );
    });

    test('sends a logged-in Register request without from to Main', () {
      expect(
        resolveAppRedirect(
          isLoggedIn: true,
          location: AppRoutes.register,
          queryParameters: const {},
        ),
        AppRoutes.main,
      );
    });
  });
}
```

- [x] **Step 2: Run the new test and confirm it fails because the redirect function does not exist**

Run:

```powershell
flutter test test/core/router/app_router_test.dart
```

Expected: compilation failure mentioning `resolveAppRedirect`.

### Task 2: Make the router keep Welcome after session restoration

**Files:**
- Modify: `lib/core/router/app_router.dart`
- Test: `test/core/router/app_router_test.dart`

- [x] **Step 1: Add the pure redirect resolver above `appRouterProvider`**

```dart
String? resolveAppRedirect({
  required bool isLoggedIn,
  required String location,
  required Map<String, String> queryParameters,
}) {
  final isAuthRoute =
      location == AppRoutes.login || location == AppRoutes.register;
  final isProtectedRoute = location.startsWith(AppRoutes.partnerDashboard);

  if (!isLoggedIn && isProtectedRoute) {
    return '${AppRoutes.login}?from=${Uri.encodeComponent(location)}';
  }

  if (isLoggedIn && isAuthRoute) {
    final from = queryParameters['from'];
    if (from != null && from.isNotEmpty) return from;
    return AppRoutes.main;
  }

  return null;
}
```

- [x] **Step 2: Replace the inline `redirect` body with the resolver call**

```dart
redirect: (context, state) => resolveAppRedirect(
  isLoggedIn: ref.read(authProvider).isLoggedIn,
  location: state.uri.path,
  queryParameters: state.uri.queryParameters,
),
```

Remove the existing condition that redirects a logged-in Welcome route to `AppRoutes.main`.

- [x] **Step 3: Make Welcome override the platform's restored initial route**

Set this GoRouter option next to `initialLocation`:

```dart
overridePlatformDefaultLocation: true,
```

Android may otherwise provide the route last restored by the app (for example `/main`), which takes priority over `initialLocation` by default.

- [x] **Step 4: Run the focused router test**

Run:

```powershell
flutter test test/core/router/app_router_test.dart
```

Expected: all six tests pass.

### Task 3: Verify the app-level regression surface and commit

**Files:**
- Modify: `docs/superpowers/plans/2026-07-15-welcome-on-every-launch.md`
- Modify: `docs/superpowers/specs/2026-07-15-welcome-on-every-launch-design.md`

- [x] **Step 1: Run static analysis and the auth regression test**

Run:

```powershell
flutter analyze
flutter test test/core/router/app_router_test.dart test/features/auth/auth_provider_test.dart
```

Expected: analysis reports no issues and all selected tests pass.

- [x] **Step 2: Perform an emulator smoke check**

Force-stop and reopen the installed application on `emulator-5554`, wait for saved-session restoration, and confirm Welcome remains on screen. Tap Explore and confirm the Main screen opens. Do not clear secure storage or log out during this check.

- [x] **Step 3: Mark completed plan items and review the final diff**

Run:

```powershell
git diff --check
git status --short
```

Expected: no whitespace errors and only the router, router test, approved design spec, and this plan changed.

- [x] **Step 4: Commit the behavioral change**

Run:

```powershell
git add lib/core/router/app_router.dart test/core/router/app_router_test.dart docs/superpowers/plans/2026-07-15-welcome-on-every-launch.md
git commit -m "feat: show welcome on every launch"
```

Expected: one focused commit containing the router behavior and regression test.

## Acceptance criteria

- [x] A saved token no longer redirects `/` away from Welcome.
- [x] A platform-restored route cannot override Welcome at launch.
- [x] Welcome still sends the user to Main when Explore is tapped.
- [x] Logged-out Partner Dashboard navigation still redirects to Login with `from`.
- [x] Logged-in Login/Register navigation still reaches `from` or Main.
- [x] Flutter analysis and focused router/auth tests pass.
