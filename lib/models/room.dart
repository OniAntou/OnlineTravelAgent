import '../core/utils/json_number.dart';

class Room {
  final String id;
  final String hotelId;
  final String name;
  final String description;
  final double price;
  final int capacity;
  final String imagePath;
  final List<String> amenities;

  const Room({
    required this.id,
    required this.hotelId,
    required this.name,
    required this.description,
    required this.price,
    required this.capacity,
    required this.imagePath,
    required this.amenities,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id']?.toString() ?? '',
      hotelId: json['hotelId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: jsonDouble(json['price']) ?? 0.0,
      capacity: jsonInt(json['capacity']) ?? 1,
      imagePath: json['imagePath']?.toString() ?? '',
      amenities: (json['amenities'] as List?)?.cast<String>() ?? [],
    );
  }
}
