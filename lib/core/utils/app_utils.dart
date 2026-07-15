/// Shared utility functions used across the app.
library;

const String kOpenStreetMapTileUrl =
    'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

/// Formats a [DateTime] into a human-readable relative time string in Vietnamese.
String getTimeAgo(DateTime dateTime) {
  final diff = DateTime.now().difference(dateTime);
  if (diff.inMinutes < 1) return 'Vừa xong';
  if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
  if (diff.inHours < 24) return '${diff.inHours} giờ trước';
  if (diff.inDays < 7) return '${diff.inDays} ngày trước';
  if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} tuần trước';
  if (diff.inDays < 365) return '${(diff.inDays / 30).floor()} tháng trước';
  return '${(diff.inDays / 365).floor()} năm trước';
}

/// Parses a reviews count string like "1.2k" or "3.5m" into a double.
double parseReviewsCount(String reviewsCount) {
  final clean = reviewsCount.toLowerCase().trim();
  double multiplier = 1.0;
  if (clean.endsWith('k')) {
    multiplier = 1000.0;
  } else if (clean.endsWith('m')) {
    multiplier = 1000000.0;
  }
  final numberOnly = clean.replaceAll(RegExp(r'[^0-9.]'), '');
  final value = double.tryParse(numberOnly) ?? 0.0;
  return value * multiplier;
}

/// Returns a Vietnamese label for the given sort key.
String getSortLabel(String sortBy) {
  switch (sortBy) {
    case 'PriceAsc':
      return 'Giá tăng dần';
    case 'PriceDesc':
      return 'Giá giảm dần';
    case 'Rating':
      return 'Đánh giá tốt';
    default:
      return 'Phổ biến nhất';
  }
}

/// Extracts a numeric price value from a price string like "$1,200" or "1.200.000₫".
double parsePrice(String price) {
  return double.tryParse(price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
}

/// Formats a price value to Vietnamese Dong (VND).
/// Example: 1500000 -> "1.500.000₫"
String formatVND(double value) {
  final fixed = value.toStringAsFixed(0);
  final buffer = StringBuffer();
  for (int i = 0; i < fixed.length; i++) {
    if (i > 0 && (fixed.length - i) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(fixed[i]);
  }
  return '$buffer₫';
}
