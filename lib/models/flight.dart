import '../core/utils/json_number.dart';

class Flight {
  final String id;
  final String airline;
  final String airlineLogo;
  final String departure;
  final String arrival;
  final String departureTime;
  final String arrivalTime;
  final int price;
  final String duration;

  const Flight({
    required this.id,
    required this.airline,
    required this.airlineLogo,
    required this.departure,
    required this.arrival,
    required this.departureTime,
    required this.arrivalTime,
    required this.price,
    required this.duration,
  });

  factory Flight.fromJson(Map<String, dynamic> json) {
    return Flight(
      id: json['id']?.toString() ?? '',
      airline: json['airline']?.toString() ?? '',
      airlineLogo: json['airlineLogo']?.toString() ?? '',
      departure: json['departure']?.toString() ?? '',
      arrival: json['arrival']?.toString() ?? '',
      departureTime: json['departureTime']?.toString() ?? '',
      arrivalTime: json['arrivalTime']?.toString() ?? '',
      price: jsonInt(json['price']) ?? 0,
      duration: json['duration']?.toString() ?? '',
    );
  }

  factory Flight.fromDb({
    required String id,
    required String airline,
    required String airlineLogo,
    required String departure,
    required String arrival,
    required String departureTime,
    required String arrivalTime,
    required int price,
    required String duration,
  }) {
    return Flight(
      id: id,
      airline: airline,
      airlineLogo: airlineLogo,
      departure: departure,
      arrival: arrival,
      departureTime: departureTime,
      arrivalTime: arrivalTime,
      price: price,
      duration: duration,
    );
  }
}
