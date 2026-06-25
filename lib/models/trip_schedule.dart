class TripScheduleUpdate {
  final String id;
  final String message;
  final DateTime createdAt;

  TripScheduleUpdate({
    required this.id,
    required this.message,
    required this.createdAt,
  });

  factory TripScheduleUpdate.fromJson(Map<String, dynamic> json) {
    return TripScheduleUpdate(
      id: json['id'] as String,
      message: json['message'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class TripScheduleItem {
  final String id;
  final String title;
  final String description;
  final String startTime;
  final String endTime;
  final String location;
  final double? latitude;
  final double? longitude;
  final String? statusOverride;

  TripScheduleItem({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.location,
    this.latitude,
    this.longitude,
    this.statusOverride,
  });

  factory TripScheduleItem.fromJson(Map<String, dynamic> json) {
    return TripScheduleItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String? ?? '',
      location: (json['location'] ?? json['locationName']) as String? ?? '',
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      statusOverride: json['statusOverride'] as String?,
    );
  }
}

class TripScheduleDay {
  final String id;
  final int dayNumber;
  final String? date;
  final List<TripScheduleItem> items;

  TripScheduleDay({
    required this.id,
    required this.dayNumber,
    this.date,
    required this.items,
  });

  factory TripScheduleDay.fromJson(Map<String, dynamic> json) {
    return TripScheduleDay(
      id: json['id'] as String,
      dayNumber: json['dayNumber'] as int,
      date: json['date'] as String?,
      items: (json['items'] as List?)
              ?.map((item) => TripScheduleItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class TripSchedule {
  final String tripId;
  final List<TripScheduleDay> days;
  final List<TripScheduleUpdate> updates;

  TripSchedule({
    required this.tripId,
    required this.days,
    required this.updates,
  });

  factory TripSchedule.fromJson(Map<String, dynamic> json) {
    return TripSchedule(
      tripId: json['tripId'] as String,
      days: (json['days'] as List?)
              ?.map((day) => TripScheduleDay.fromJson(day as Map<String, dynamic>))
              .toList() ??
          [],
      updates: (json['updates'] as List?)
              ?.map((update) => TripScheduleUpdate.fromJson(update as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
