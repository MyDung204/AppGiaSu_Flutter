class Review {
  final String id;
  final String bookingId; // Link to specific booking
  final String tutorId;
  final String userId;
  final String userName;
  final String userAvatar;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final bool isVisible; // Blind Review Logic

  Review({
    required this.id,
    required this.bookingId,
    required this.tutorId,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.isVisible = false,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'].toString(),
      bookingId: (json['booking_id'] ?? '').toString(),
      tutorId: (json['tutor_id'] ?? '').toString(),
      userId: (json['reviewer_id'] ?? '').toString(),
      userName: json['reviewer_name'] ?? 'Học viên',
      userAvatar: json['reviewer_avatar'] ?? '',
      rating: double.tryParse((json['rating'] ?? 0).toString()) ?? 0,
      comment: json['comment'] ?? '',
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()) ??
          DateTime.now(),
      isVisible: false,
    );
  }

  Review copyWith({
    String? id,
    String? bookingId,
    String? tutorId,
    String? userId,
    String? userName,
    String? userAvatar,
    double? rating,
    String? comment,
    DateTime? createdAt,
    bool? isVisible,
  }) {
    return Review(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      tutorId: tutorId ?? this.tutorId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      isVisible: isVisible ?? this.isVisible,
    );
  }
}

class ReviewStatus {
  final bool canReview;
  final bool hasReview;
  final Review? review;

  const ReviewStatus({
    required this.canReview,
    required this.hasReview,
    this.review,
  });

  factory ReviewStatus.fromJson(Map<String, dynamic> json) {
    final reviewJson = json['review'];
    return ReviewStatus(
      canReview: json['can_review'] == true,
      hasReview: json['has_review'] == true,
      review: reviewJson is Map<String, dynamic>
          ? Review.fromJson(reviewJson)
          : null,
    );
  }
}
