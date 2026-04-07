import '../../domain/entities/review_entity.dart';

abstract class ReviewState {}

class ReviewInitial extends ReviewState {}

class ReviewLoading extends ReviewState {}

class ReviewLoaded extends ReviewState {
  final List<ReviewEntity> reviews;

  ReviewLoaded(this.reviews);
}

class ReviewSubmitting extends ReviewState {}

class ReviewSuccess extends ReviewState {
  final String message;

  ReviewSuccess(this.message);
}

class ReviewFailure extends ReviewState {
  final String message;

  ReviewFailure(this.message);
}
