import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/hotel.dart';
import '../../../app/state/app_state_provider.dart';

final hotelsProvider = Provider<List<Hotel>>((ref) {
  final bootstrap = ref.watch(bootstrapProvider).value;
  return bootstrap?.hotels ?? [];
});
