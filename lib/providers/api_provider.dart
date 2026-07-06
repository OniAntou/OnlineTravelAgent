
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/travel_api_service.dart';
import 'auth_provider.dart';

final apiProvider = Provider<TravelApiService>((ref) {
  final api = TravelApiService();
  api.onAuthError = () {
    Future.microtask(() {
      ref.read(authProvider.notifier).logout();
    });
  };
  return api;
});
