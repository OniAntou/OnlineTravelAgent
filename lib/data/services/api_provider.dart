import 'package:flutter_riverpod/flutter_riverpod.dart';
import './travel_api_service.dart';
import '../../features/auth/application/auth_provider.dart';

final apiProvider = Provider<TravelApiService>((ref) {
  final api = TravelApiService();
  api.onAuthError = () {
    Future.microtask(() async {
      await ref.read(authProvider.notifier).logout();
    });
  };
  ref.onDispose(api.dispose);
  return api;
});
