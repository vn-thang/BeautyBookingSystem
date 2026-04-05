import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_review.dart';
import '../../domain/usecases/get_my_reviews.dart';
import 'review_event.dart';
import 'review_state.dart';

class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final GetMyReviews getMyReviews;
  final CreateReview createReview;

  ReviewBloc({
    required this.getMyReviews,
    required this.createReview,
  }) : super(ReviewInitial()) {
    on<LoadMyReviews>(_onLoadMyReviews);
    on<SubmitReview>(_onSubmitReview);
  }

  Future<void> _onLoadMyReviews(
    LoadMyReviews event,
    Emitter<ReviewState> emit,
  ) async {
    emit(ReviewLoading());
    try {
      final reviews = await getMyReviews();
      emit(ReviewLoaded(reviews));
    } catch (e) {
      emit(ReviewFailure(e.toString()));
    }
  }

  Future<void> _onSubmitReview(
    SubmitReview event,
    Emitter<ReviewState> emit,
  ) async {
    emit(ReviewSubmitting());
    try {
      await createReview(
        bookingId: event.bookingId,
        rating: event.rating,
        comment: event.comment,
      );
      emit(ReviewSuccess('Đánh giá thành công'));
      final reviews = await getMyReviews();
      emit(ReviewLoaded(reviews));
    } catch (e) {
      emit(ReviewFailure(e.toString()));
    }
  }
}
