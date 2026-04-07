class CreateReviewRequestModel {
  final int bookingId;
  final int rating;
  final String? comment;

  CreateReviewRequestModel({
    required this.bookingId,
    required this.rating,
    this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'rating': rating,
      'comment': comment,
    };
  }
}
