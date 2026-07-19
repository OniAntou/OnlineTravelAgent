import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/services/api_provider.dart';
import '../domain/trip_change_request.dart';

final tripChangeRequestsProvider = FutureProvider.autoDispose
    .family<List<TripChangeRequest>, String>((ref, tripId) async {
      final api = ref.watch(apiProvider);
      await api.loadTokenFuture;
      return api.fetchTripChangeRequests(tripId);
    });
