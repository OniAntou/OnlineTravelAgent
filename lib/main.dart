import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/welcome/welcome_screen.dart';
import 'screens/main/main_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/partner/partner_dashboard_screen.dart';
import 'core/theme/app_theme.dart';
import 'providers/app_state_provider.dart';
import 'services/sync_service.dart';
import 'services/connectivity_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: OnlineTravelAgentApp()));
}

class OnlineTravelAgentApp extends ConsumerStatefulWidget {
  const OnlineTravelAgentApp({super.key});

  @override
  ConsumerState<OnlineTravelAgentApp> createState() =>
      _OnlineTravelAgentAppState();
}

class _OnlineTravelAgentAppState extends ConsumerState<OnlineTravelAgentApp>
    with WidgetsBindingObserver {
  late final SyncService _syncService;
  late final ConnectivityService _connectivityService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _syncService = ref.read(syncServiceProvider);
    _connectivityService = ref.read(connectivityServiceProvider);

    // Start periodic sync
    _syncService.startPeriodicSync();

    // Listen for reconnect events
    _connectivityService.onReconnect.listen((_) {
      _syncService.syncAll();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _syncService.dispose();
    _connectivityService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final syncService = ref.read(syncServiceProvider);

    switch (state) {
      case AppLifecycleState.resumed:
        // App comes to foreground - sync and restart periodic
        syncService.syncAll();
        syncService.startPeriodicSync();
        break;
      case AppLifecycleState.paused:
        // App goes to background - stop periodic sync
        syncService.stopPeriodicSync();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Activate bootstrap sync (profile + documents from bootstrap data)
    ref.watch(bootstrapSyncProvider);

    return MaterialApp(
      title: 'Online Travel Agent',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/main': (context) => const MainScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/partner-dashboard': (context) => const PartnerDashboardScreen(),
      },
    );
  }
}
