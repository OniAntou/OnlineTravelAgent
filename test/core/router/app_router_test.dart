import 'package:flutter_test/flutter_test.dart';
import 'package:online_travel_agent/core/router/app_router.dart';
import 'package:online_travel_agent/core/router/app_routes.dart';

void main() {
  group('resolveAppRedirect', () {
    test('keeps a logged-in user on Welcome', () {
      expect(
        resolveAppRedirect(
          isLoggedIn: true,
          location: AppRoutes.welcome,
          queryParameters: const {},
        ),
        isNull,
      );
    });

    test('keeps a logged-out user on Welcome', () {
      expect(
        resolveAppRedirect(
          isLoggedIn: false,
          location: AppRoutes.welcome,
          queryParameters: const {},
        ),
        isNull,
      );
    });

    test('sends a logged-out partner user to Login with a return path', () {
      expect(
        resolveAppRedirect(
          isLoggedIn: false,
          location: AppRoutes.partnerDashboard,
          queryParameters: const {},
        ),
        '${AppRoutes.login}?from=${Uri.encodeComponent(AppRoutes.partnerDashboard)}',
      );
    });

    test('returns a logged-in user to the requested path after Login', () {
      expect(
        resolveAppRedirect(
          isLoggedIn: true,
          location: AppRoutes.login,
          queryParameters: const {'from': AppRoutes.partnerDashboard},
        ),
        AppRoutes.partnerDashboard,
      );
    });

    test('sends a logged-in user from Login to Main without a return path', () {
      expect(
        resolveAppRedirect(
          isLoggedIn: true,
          location: AppRoutes.login,
          queryParameters: const {},
        ),
        AppRoutes.main,
      );
    });

    test(
      'sends a logged-in user from Register to Main without a return path',
      () {
        expect(
          resolveAppRedirect(
            isLoggedIn: true,
            location: AppRoutes.register,
            queryParameters: const {},
          ),
          AppRoutes.main,
        );
      },
    );
  });
}
