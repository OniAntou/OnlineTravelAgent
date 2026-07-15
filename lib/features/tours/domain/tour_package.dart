import '../../../core/utils/json_number.dart';

class TourPackage {
  final String id;
  final String name;
  final String description;
  final String imagePath;
  final String duration;
  final double price;
  final double? originalPrice;
  final List<String> destinations;
  final List<String> includes;
  final String departure;
  final String? departureDate;
  final bool isPopular;
  final bool includesGuide;
  final double guideFee;

  const TourPackage({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
    required this.duration,
    required this.price,
    this.originalPrice,
    required this.destinations,
    required this.includes,
    required this.departure,
    this.departureDate,
    this.isPopular = false,
    this.includesGuide = true,
    this.guideFee = 50.0,
  });

  factory TourPackage.fromJson(Map<String, dynamic> json) {
    return TourPackage(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      imagePath: json['imagePath']?.toString() ?? '',
      duration: json['duration']?.toString() ?? '',
      price: jsonDouble(json['price']) ?? 0.0,
      originalPrice: jsonDouble(json['originalPrice']),
      destinations: (json['destinations'] as List?)?.cast<String>() ?? [],
      includes: (json['includes'] as List?)?.cast<String>() ?? [],
      departure: json['departure']?.toString() ?? '',
      departureDate: json['departureDate']?.toString(),
      isPopular: json['isPopular'] == true,
      includesGuide: json['includesGuide'] != false,
      guideFee: jsonDouble(json['guideFee']) ?? 50.0,
    );
  }
}
