import '../../../core/utils/json_number.dart';

enum TripStatus {
  pendingPayment('pending_payment', 'Chờ thanh toán'),
  upcoming('upcoming', 'Sắp tới'),
  ongoing('ongoing', 'Đang diễn ra'),
  completed('completed', 'Đã hoàn thành'),
  cancelled('cancelled', 'Đã hủy'),
  unknown('unknown', 'Không xác định');

  const TripStatus(this.storageValue, this.displayLabel);

  final String storageValue;
  final String displayLabel;

  static TripStatus fromServer(
    String rawStatus,
    String rawPaymentStatus,
    bool isUpcoming,
  ) {
    if (rawPaymentStatus.trim().toUpperCase() == 'PENDING') {
      return TripStatus.pendingPayment;
    }

    switch (rawStatus.trim().toUpperCase()) {
      case 'ONGOING':
        return isUpcoming ? TripStatus.upcoming : TripStatus.ongoing;
      case 'COMPLETED':
        return TripStatus.completed;
      case 'CANCELLED':
      case 'CANCELED':
        return TripStatus.cancelled;
      default:
        return TripStatus.fromStorage(rawStatus, isUpcoming);
    }
  }

  static TripStatus fromStorage(String rawStatus, bool isUpcoming) {
    final normalized = rawStatus.trim().toLowerCase();
    switch (normalized) {
      case 'pending_payment':
      case 'pending':
      case 'chờ thanh toán':
      case 'cho thanh toan':
        return TripStatus.pendingPayment;
      case 'upcoming':
      case 'sắp tới':
      case 'sap toi':
        return TripStatus.upcoming;
      case 'ongoing':
      case 'đang diễn ra':
      case 'dang dien ra':
        return TripStatus.ongoing;
      case 'completed':
      case 'đã hoàn thành':
      case 'da hoan thanh':
      case 'đã đi':
      case 'da di':
        return TripStatus.completed;
      case 'cancelled':
      case 'canceled':
      case 'đã hủy':
      case 'đã huỷ':
      case 'da huy':
        return TripStatus.cancelled;
      case 'unknown':
        return TripStatus.unknown;
      default:
        return isUpcoming ? TripStatus.upcoming : TripStatus.unknown;
    }
  }
}

class Trip {
  final String id;
  final String destination;
  final String location;
  final String date;
  final String guests;
  final TripStatus status;
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
    return Trip(
      id: json['id']?.toString() ?? '',
      destination: json['destination']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      guests: json['guests']?.toString() ?? '',
      status: TripStatus.fromServer(rawStatus, rawPaymentStatus, isUpcoming),
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
