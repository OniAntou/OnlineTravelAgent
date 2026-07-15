import '../core/utils/json_number.dart';

class Trip {
  final String id;
  final String destination;
  final String location;
  final String date;
  final String guests;
  final String status;
  final String imagePath;
  final bool isUpcoming;
  final String? flightId;
  final String? hotelId;
  final String? roomId;
  final double? totalPrice;
  final bool isCustom;

  const Trip({
    required this.id,
    required this.destination,
    required this.location,
    required this.date,
    required this.guests,
    required this.status,
    required this.imagePath,
    this.isUpcoming = true,
    this.flightId,
    this.hotelId,
    this.roomId,
    this.totalPrice,
    this.isCustom = false,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    final String rawStatus = json['status']?.toString() ?? '';
    final bool isUpcoming = json['isUpcoming'] == true;
    final String rawPaymentStatus = json['paymentStatus']?.toString() ?? '';
    String mappedStatus = rawStatus;

    if (rawPaymentStatus == 'PENDING') {
      mappedStatus = 'Chờ thanh toán';
    } else if (rawStatus == 'ONGOING') {
      if (isUpcoming) {
        mappedStatus = 'Sắp tới';
      } else {
        mappedStatus = 'Đang diễn ra';
      }
    } else if (rawStatus == 'COMPLETED') {
      mappedStatus = 'Đã hoàn thành';
    } else if (rawStatus == 'CANCELLED') {
      mappedStatus = 'Đã hủy';
    }

    return Trip(
      id: json['id']?.toString() ?? '',
      destination: json['destination']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      guests: json['guests']?.toString() ?? '',
      status: mappedStatus,
      imagePath: json['imagePath']?.toString() ?? '',
      isUpcoming: isUpcoming,
      flightId: json['flightId']?.toString(),
      hotelId: json['hotelId']?.toString(),
      roomId: json['roomId']?.toString(),
      totalPrice: jsonDouble(json['totalPrice']),
      isCustom: json['isCustom'] == true,
    );
  }
}
