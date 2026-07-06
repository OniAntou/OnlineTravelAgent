class Review {
  final String id;
  final String userId;
  final String userName;
  final String targetType;
  final String targetId;
  final int rating;
  final String comment;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.userId,
    required this.userName,
    required this.targetType,
    required this.targetId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    return Review(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      userName: user?['name']?.toString() ?? 'Ẩn danh',
      targetType: json['targetType']?.toString() ?? '',
      targetId: json['targetId']?.toString() ?? '',
      rating: (json['rating'] as num?)?.toInt() ?? 5,
      comment: json['comment']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

class ReviewResponse {
  final List<Review> reviews;
  final int total;
  final double avgRating;

  const ReviewResponse({
    required this.reviews,
    required this.total,
    required this.avgRating,
  });

  factory ReviewResponse.fromJson(Map<String, dynamic> json) {
    final reviewsList = (json['reviews'] as List?) ?? [];
    return ReviewResponse(
      reviews: reviewsList
          .map((r) => Review.fromJson(r as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num?)?.toInt() ?? 0,
      avgRating: (json['avgRating'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
