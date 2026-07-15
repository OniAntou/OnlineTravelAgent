import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../app/shell/main_screen.dart';
import '../../features/partner/presentation/partner_dashboard_screen.dart';
import '../../features/welcome/presentation/welcome_screen.dart';
import '../../features/auth/application/auth_provider.dart';
import 'app_routes.dart';

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

final rootNavigatorKeyProvider = Provider<GlobalKey<NavigatorState>>(
  (ref) => GlobalKey<NavigatorState>(),
);

final appRouterProvider = Provider<GoRouter>((ref) {
  final rootNavigatorKey = ref.watch(rootNavigatorKeyProvider);
  late final GoRouter router;
  router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.welcome,
    overridePlatformDefaultLocation: true,
    redirect: (context, state) => resolveAppRedirect(
      isLoggedIn: ref.read(authProvider).isLoggedIn,
      location: state.uri.path,
      queryParameters: state.uri.queryParameters,
    ),
    routes: [
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.main,
        builder: (context, state) => const MainScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.partnerDashboard,
        builder: (context, state) => const PartnerDashboardScreen(),
      ),
    ],
  );
  ref.listen(authProvider, (_, _) => router.refresh());
  return router;
});
