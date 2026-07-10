double? jsonDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

int? jsonInt(Object? value) {
  if (value is num) return value.toInt();
  if (value is String) return double.tryParse(value)?.toInt();
  return null;
}
