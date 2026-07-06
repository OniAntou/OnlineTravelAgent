import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/hotel.dart';
import 'app_state_provider.dart';

final hotelsProvider = Provider<List<Hotel>>((ref) {
  final bootstrap = ref.watch(bootstrapProvider).value;
  return bootstrap?.hotels ?? [];
});

class HotelSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String query) {
    state = query;
  }
}

final hotelSearchQueryProvider =
    NotifierProvider<HotelSearchQueryNotifier, String>(
      HotelSearchQueryNotifier.new,
    );
