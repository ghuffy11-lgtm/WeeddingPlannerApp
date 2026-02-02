import '../../domain/entities/review.dart';

/// Review data model for JSON serialization
class ReviewModel extends Review {
  const ReviewModel({
    required super.id,
    super.weddingId,
    required super.vendorId,
    required super.rating,
    super.comment,
    super.vendorResponse,
    required super.createdAt,
    super.reviewerName,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      weddingId: json['wedding_id'] as String?,
      vendorId: json['vendor_id'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      vendorResponse: json['vendor_response'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      reviewerName: json['reviewer_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'wedding_id': weddingId,
      'vendor_id': vendorId,
      'rating': rating,
      'comment': comment,
      'vendor_response': vendorResponse,
      'created_at': createdAt.toIso8601String(),
      'reviewer_name': reviewerName,
    };
  }
}
