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

final rootNavigatorKeyProvider = Provider<GlobalKey<NavigatorState>>((ref) => GlobalKey<NavigatorState>());

final appRouterProvider = Provider<GoRouter>((ref) {
  final rootNavigatorKey = ref.watch(rootNavigatorKeyProvider);
  late final GoRouter router;
  router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.welcome,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final location = state.uri.path;
      final isAuthRoute =
          location == AppRoutes.login || location == AppRoutes.register;
          
      final protectedPrefixes = [
        AppRoutes.partnerDashboard,
      ];
      final isProtectedRoute = protectedPrefixes.any(location.startsWith);

      if (!authState.isLoggedIn && isProtectedRoute) {
        return '${AppRoutes.login}?from=${Uri.encodeComponent(location)}';
      }

      if (authState.isLoggedIn && isAuthRoute) {
        final from = state.uri.queryParameters['from'];
        if (from != null && from.isNotEmpty) return from;
        return AppRoutes.main;
      }

      if (authState.isLoggedIn && location == AppRoutes.welcome) {
        return AppRoutes.main;
      }

      return null;
    },
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
