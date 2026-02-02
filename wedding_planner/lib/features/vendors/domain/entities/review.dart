/// Review entity
class Review {
  final String id;
  final String? weddingId;
  final String vendorId;
  final int rating;
  final String? comment;
  final String? vendorResponse;
  final DateTime createdAt;
  final String? reviewerName;

  const Review({
    required this.id,
    this.weddingId,
    required this.vendorId,
    required this.rating,
    this.comment,
    this.vendorResponse,
    required this.createdAt,
    this.reviewerName,
  });

  /// Check if vendor has responded
  bool get hasResponse => vendorResponse != null && vendorResponse!.isNotEmpty;

  /// Get rating display (stars)
  String get ratingDisplay => List.filled(rating, '★').join() + List.filled(5 - rating, '☆').join();
}
