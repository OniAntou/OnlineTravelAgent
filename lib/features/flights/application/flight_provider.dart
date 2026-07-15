import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/app_database.dart';
import '../domain/flight.dart';
import '../../../data/services/api_provider.dart';

final flightsProvider = FutureProvider<List<Flight>>((ref) async {
  final db = AppDatabase.instance();
  final local = await db.flightsDao.getAll();
  if (local.isNotEmpty) {
    return local
        .map(
          (row) => Flight.fromDb(
            id: row.id,
            airline: row.airline,
            airlineLogo: row.airlineLogo,
            departure: row.departure,
            arrival: row.arrival,
            departureTime: row.departureTime,
            arrivalTime: row.arrivalTime,
            price: row.price,
            duration: row.duration,
          ),
        )
        .toList(growable: false);
  }

  final api = ref.read(apiProvider);
  return api.searchFlights(null, null);
});
