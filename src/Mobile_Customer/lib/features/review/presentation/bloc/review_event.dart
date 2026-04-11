abstract class ReviewEvent {}

class LoadMyReviews extends ReviewEvent {}

class SubmitReview extends ReviewEvent {
  final int bookingId;
  final int rating;
  final String? comment;

  SubmitReview({
    required this.bookingId,
    required this.rating,
    this.comment,
  });
}
