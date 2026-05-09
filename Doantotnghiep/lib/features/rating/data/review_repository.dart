import 'package:doantotnghiep/core/network/api_client.dart';
import 'package:doantotnghiep/core/network/api_constants.dart';
import 'package:doantotnghiep/features/rating/domain/models/review.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ApiReviewRepository(ref.read(apiClientProvider));
});

abstract class ReviewRepository {
  Future<List<Review>> getReviewsForTutor(String tutorId);
  Future<ReviewStatus> getMyReviewStatus(String tutorId);
  Future<Review> submitTutorReview(
    String tutorId, {
    required int rating,
    String? comment,
  });
}

class ApiReviewRepository implements ReviewRepository {
  final ApiClient _apiClient;

  ApiReviewRepository(this._apiClient);

  @override
  Future<List<Review>> getReviewsForTutor(String tutorId) async {
    final response = await _apiClient.get('${ApiConstants.tutors}/$tutorId/reviews');
    if (response is! List) return [];
    return response
        .whereType<Map<String, dynamic>>()
        .map(Review.fromJson)
        .toList();
  }

  @override
  Future<ReviewStatus> getMyReviewStatus(String tutorId) async {
    final response = await _apiClient.get(
      '${ApiConstants.tutors}/$tutorId/my-review-status',
    );
    if (response is! Map<String, dynamic>) {
      return const ReviewStatus(canReview: false, hasReview: false);
    }
    return ReviewStatus.fromJson(response);
  }

  @override
  Future<Review> submitTutorReview(
    String tutorId, {
    required int rating,
    String? comment,
  }) async {
    final response = await _apiClient.post(
      '${ApiConstants.tutors}/$tutorId/reviews',
      data: {
        'rating': rating,
        if (comment != null && comment.trim().isNotEmpty) 'comment': comment.trim(),
      },
    );

    if (response is Map<String, dynamic> && response['review'] is Map<String, dynamic>) {
      return Review.fromJson(response['review'] as Map<String, dynamic>);
    }

    throw Exception('Không nhận được dữ liệu đánh giá từ máy chủ.');
  }
}
