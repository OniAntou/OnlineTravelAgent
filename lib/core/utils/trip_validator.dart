import 'api_exception.dart';

class TripValidator {
  static String requiredText(String? value, String field) {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty) {
      throw ValidationException(message: '$field không được để trống');
    }
    return normalized;
  }

  static String requiredGuests(String? guests) {
    final normalized = requiredText(guests, 'Số khách');
    if (!RegExp(r'[1-9]\d*').hasMatch(normalized)) {
      throw const ValidationException(message: 'Số khách phải lớn hơn 0');
    }
    return normalized;
  }

  static DateTime requiredDate(String value, String field) {
    final parsed = parseDate(value);
    if (parsed == null) {
      throw ValidationException(message: '$field không hợp lệ');
    }
    return parsed;
  }

  static DateTime? parseDate(String value) {
    final normalized = value.trim();
    final vietnameseDate = RegExp(
      r'^(\d{1,2})/(\d{1,2})/(\d{4})$',
    ).firstMatch(normalized);

    if (vietnameseDate != null) {
      final day = int.parse(vietnameseDate.group(1)!);
      final month = int.parse(vietnameseDate.group(2)!);
      final year = int.parse(vietnameseDate.group(3)!);
      final date = DateTime(year, month, day);
      if (date.year == year && date.month == month && date.day == day) {
        return date;
      }
      return null;
    }

    final isoDate = DateTime.tryParse(normalized);
    if (isoDate == null) return null;
    return DateTime(isoDate.year, isoDate.month, isoDate.day);
  }

  static void validateHotelStay({required String checkIn, required String checkOut}) {
    final checkInDate = requiredDate(checkIn, 'Ngày nhận phòng');
    final checkOutDate = requiredDate(checkOut, 'Ngày trả phòng');

    if (!checkOutDate.isAfter(checkInDate)) {
      throw const ValidationException(
        message: 'Ngày trả phòng phải sau ngày nhận phòng',
      );
    }
  }
}
