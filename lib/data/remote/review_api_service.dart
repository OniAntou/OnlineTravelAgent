import '../../shared/models/review.dart';
import 'api_http_client.dart';

class ReviewApiService {
  final ApiHttpClient _client;
  ReviewApiService(this._client);

  Future<ReviewResponse> getReviews({
    required String targetType,
    required String targetId,
    String? cursor,
    int limit = 20,
  }) async {
    final data = await _client.getJson(
      _client.pathWithQuery('/api/reviews', {
        'targetType': targetType,
        'targetId': targetId,
        'cursor': cursor,
        'limit': limit.toString(),
      }),
    );
    return ReviewResponse.fromJson(data);
  }

  Future<Review> createReview({
    required String targetType,
    required String targetId,
    required int rating,
    required String comment,
  }) async {
    final data = await _client.postJson('/api/reviews', {
      'targetType': targetType,
      'targetId': targetId,
      'rating': rating,
      'comment': comment,
    });
    return Review.fromJson(data);
  }

  Future<bool> deleteReview(String reviewId) async {
    await _client.delete('/api/reviews/$reviewId');
    return true;
  }
}
