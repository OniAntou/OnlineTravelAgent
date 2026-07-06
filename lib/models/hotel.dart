import 'room.dart';

class Hotel {
  final String id;
  final String name;
  final String location;
  final double latitude;
  final double longitude;
  final String rating;
  final String imagePath;
  final String description;
  final double priceFrom;
  final String address;
  final List<String> amenities;
  final List<Room> rooms;

  const Hotel({
    required this.id,
    required this.name,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.imagePath,
    required this.description,
    required this.priceFrom,
    required this.address,
    required this.amenities,
    this.rooms = const [],
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      rating: json['rating']?.toString() ?? '',
      imagePath: json['imagePath']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      priceFrom: (json['priceFrom'] as num?)?.toDouble() ?? 0.0,
      address: json['address']?.toString() ?? '',
      amenities: (json['amenities'] as List?)?.cast<String>() ?? [],
      rooms:
          (json['rooms'] as List?)?.map((e) => Room.fromJson(e)).toList() ?? [],
    );
  }
}
