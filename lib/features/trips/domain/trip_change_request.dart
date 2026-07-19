import '../../../core/utils/json_number.dart';

enum TripChangeRequestType {
  reschedule('RESCHEDULE', 'Đổi lịch'),
  refund('REFUND', 'Yêu cầu hoàn tiền'),
  unknown('UNKNOWN', 'Yêu cầu thay đổi');

  const TripChangeRequestType(this.serverValue, this.displayLabel);

  final String serverValue;
  final String displayLabel;

  static TripChangeRequestType fromServer(String value) {
    return TripChangeRequestType.values.firstWhere(
      (type) => type.serverValue == value.trim().toUpperCase(),
      orElse: () => TripChangeRequestType.unknown,
    );
  }
}

enum TripChangeRequestStatus {
  pending('PENDING', 'Đang chờ xử lý'),
  approved('APPROVED', 'Đã duyệt'),
  rejected('REJECTED', 'Từ chối'),
  unknown('UNKNOWN', 'Không xác định');

  const TripChangeRequestStatus(this.serverValue, this.displayLabel);

  final String serverValue;
  final String displayLabel;

  static TripChangeRequestStatus fromServer(String value) {
    return TripChangeRequestStatus.values.firstWhere(
      (status) => status.serverValue == value.trim().toUpperCase(),
      orElse: () => TripChangeRequestStatus.unknown,
    );
  }
}

class TripChangeRequest {
  final String id;
  final String tripId;
  final TripChangeRequestType type;
  final TripChangeRequestStatus status;
  final String reason;
  final String? requestedDate;
  final double? refundAmount;
  final String? adminNote;
  final DateTime? reviewedAt;
  final DateTime? createdAt;

  const TripChangeRequest({
    required this.id,
    required this.tripId,
    required this.type,
    required this.status,
    required this.reason,
    this.requestedDate,
    this.refundAmount,
    this.adminNote,
    this.reviewedAt,
    this.createdAt,
  });

  bool get isPending => status == TripChangeRequestStatus.pending;

  factory TripChangeRequest.fromJson(Map<String, dynamic> json) {
    String? optionalText(dynamic value) {
      final text = value?.toString().trim();
      return text == null || text.isEmpty ? null : text;
    }

    DateTime? optionalDate(dynamic value) {
      final text = optionalText(value);
      return text == null ? null : DateTime.tryParse(text);
    }

    return TripChangeRequest(
      id: json['id']?.toString() ?? '',
      tripId: json['tripId']?.toString() ?? '',
      type: TripChangeRequestType.fromServer(json['type']?.toString() ?? ''),
      status: TripChangeRequestStatus.fromServer(
        json['status']?.toString() ?? '',
      ),
      reason: json['reason']?.toString() ?? '',
      requestedDate: optionalText(json['requestedDate']),
      refundAmount: jsonDouble(json['refundAmount']),
      adminNote: optionalText(json['adminNote']),
      reviewedAt: optionalDate(json['reviewedAt']),
      createdAt: optionalDate(json['createdAt']),
    );
  }
}
