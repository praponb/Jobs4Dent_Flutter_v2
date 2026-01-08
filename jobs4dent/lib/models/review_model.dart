class ReviewModel {
  final String reviewId;
  final String reviewerId;
  final String reviewerName;
  final String reviewerType; // dentist, clinic, seller
  final String targetId; // ID of the entity being reviewed
  final String targetType; // clinic, dentist, product, seller
  final String targetName;
  final double rating; // 1-5 stars
  final String title;
  final String content;
  final List<String> pros;
  final List<String> cons;
  final List<String> imageUrls;
  final bool isVerified;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int helpfulCount;
  final int totalVotes;
  final String? moderatorNotes;
  final ReviewStatus status;

  ReviewModel({
    required this.reviewId,
    required this.reviewerId,
    required this.reviewerName,
    required this.reviewerType,
    required this.targetId,
    required this.targetType,
    required this.targetName,
    required this.rating,
    required this.title,
    required this.content,
    this.pros = const [],
    this.cons = const [],
    this.imageUrls = const [],
    this.isVerified = false,
    this.isPublic = true,
    required this.createdAt,
    required this.updatedAt,
    this.helpfulCount = 0,
    this.totalVotes = 0,
    this.moderatorNotes,
    this.status = ReviewStatus.pending,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      reviewId: map['reviewId'] ?? '',
      reviewerId: map['reviewerId'] ?? '',
      reviewerName: map['reviewerName'] ?? '',
      reviewerType: map['reviewerType'] ?? '',
      targetId: map['targetId'] ?? '',
      targetType: map['targetType'] ?? '',
      targetName: map['targetName'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      pros: List<String>.from(map['pros'] ?? []),
      cons: List<String>.from(map['cons'] ?? []),
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      isVerified: map['isVerified'] ?? false,
      isPublic: map['isPublic'] ?? true,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
      helpfulCount: map['helpfulCount'] ?? 0,
      totalVotes: map['totalVotes'] ?? 0,
      moderatorNotes: map['moderatorNotes'],
      status: ReviewStatus.values.firstWhere(
        (status) => status.name == map['status'],
        orElse: () => ReviewStatus.pending,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reviewId': reviewId,
      'reviewerId': reviewerId,
      'reviewerName': reviewerName,
      'reviewerType': reviewerType,
      'targetId': targetId,
      'targetType': targetType,
      'targetName': targetName,
      'rating': rating,
      'title': title,
      'content': content,
      'pros': pros,
      'cons': cons,
      'imageUrls': imageUrls,
      'isVerified': isVerified,
      'isPublic': isPublic,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'helpfulCount': helpfulCount,
      'totalVotes': totalVotes,
      'moderatorNotes': moderatorNotes,
      'status': status.name,
    };
  }

  ReviewModel copyWith({
    String? reviewId,
    String? reviewerId,
    String? reviewerName,
    String? reviewerType,
    String? targetId,
    String? targetType,
    String? targetName,
    double? rating,
    String? title,
    String? content,
    List<String>? pros,
    List<String>? cons,
    List<String>? imageUrls,
    bool? isVerified,
    bool? isPublic,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? helpfulCount,
    int? totalVotes,
    String? moderatorNotes,
    ReviewStatus? status,
  }) {
    return ReviewModel(
      reviewId: reviewId ?? this.reviewId,
      reviewerId: reviewerId ?? this.reviewerId,
      reviewerName: reviewerName ?? this.reviewerName,
      reviewerType: reviewerType ?? this.reviewerType,
      targetId: targetId ?? this.targetId,
      targetType: targetType ?? this.targetType,
      targetName: targetName ?? this.targetName,
      rating: rating ?? this.rating,
      title: title ?? this.title,
      content: content ?? this.content,
      pros: pros ?? this.pros,
      cons: cons ?? this.cons,
      imageUrls: imageUrls ?? this.imageUrls,
      isVerified: isVerified ?? this.isVerified,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      totalVotes: totalVotes ?? this.totalVotes,
      moderatorNotes: moderatorNotes ?? this.moderatorNotes,
      status: status ?? this.status,
    );
  }

  double get helpfulRatio => totalVotes > 0 ? helpfulCount / totalVotes : 0.0;
}

enum ReviewStatus {
  pending,
  approved,
  rejected,
  flagged,
  hidden,
} 