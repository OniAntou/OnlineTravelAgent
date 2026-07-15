int? _clockMinutes(String value) {
  final match = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$').firstMatch(value);
  if (match == null) return null;
  return int.parse(match.group(1)!) * 60 + int.parse(match.group(2)!);
}

DateTime? _dateOnly(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final parsed = DateTime.tryParse(value.trim());
  if (parsed == null) return null;
  return DateTime(parsed.year, parsed.month, parsed.day);
}

String deriveTripScheduleMilestoneStatus({
  required String tripStatus,
  required String? scheduleDate,
  required String startTime,
  required String endTime,
  String? nextStartTime,
  String? statusOverride,
  DateTime? now,
}) {
  if (statusOverride != null && statusOverride.isNotEmpty) {
    return statusOverride;
  }

  final normalizedTripStatus = tripStatus.trim().toLowerCase();
  if ({
    'đã đi',
    'hoàn thành',
    'đã hoàn thành',
    'completed',
  }.contains(normalizedTripStatus)) {
    return 'completed';
  }
  if ({'đã hủy', 'đã huỷ', 'cancelled', 'canceled'}.contains(normalizedTripStatus)) {
    return 'cancelled';
  }
  if ({'sắp tới', 'upcoming'}.contains(normalizedTripStatus)) {
    return 'upcoming';
  }

  final current = now ?? DateTime.now();
  final itemDate = _dateOnly(scheduleDate);
  if (itemDate != null) {
    final today = DateTime(current.year, current.month, current.day);
    if (itemDate.isBefore(today)) return 'completed';
    if (itemDate.isAfter(today)) return 'upcoming';
  }

  final start = _clockMinutes(startTime);
  if (start == null) return 'upcoming';

  final currentMinutes = current.hour * 60 + current.minute;
  if (currentMinutes < start) return 'upcoming';

  final end = _clockMinutes(endTime);
  if (end != null && end > start) {
    return currentMinutes < end ? 'ongoing' : 'completed';
  }

  final nextStart = nextStartTime == null
      ? null
      : _clockMinutes(nextStartTime);
  if (nextStart != null && currentMinutes >= nextStart) {
    return 'completed';
  }
  return 'ongoing';
}
