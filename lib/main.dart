import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'app/state/app_state_provider.dart';
import 'data/services/sync_service.dart';
import 'data/services/connectivity_service.dart';

import 'dart:ui';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Flutter Error: ${details.exception}');
  };
  
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint('Async Error: $error\n$stack');
    return true;
  };

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('vi'), Locale('en')],
      path: 'assets/translations',
      startLocale: const Locale('vi'),
      fallbackLocale: const Locale('vi'),
      child: const ProviderScope(child: OnlineTravelAgentApp()),
    ),
  );
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
    ref.watch(bootstrapSyncProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Online Travel Agent',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      routerConfig: router,
    );
  }
}
