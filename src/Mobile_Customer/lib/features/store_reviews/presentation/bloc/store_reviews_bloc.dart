import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/store_review_entity.dart';
import '../../domain/usecases/get_store_reviews_usecase.dart';

sealed class StoreReviewsEvent {}

class LoadStoreReviews extends StoreReviewsEvent {
  final int storeId;
  final int page;
  final int pageSize;
  final bool append;

  LoadStoreReviews({
    required this.storeId,
    this.page = 1,
    this.pageSize = 10,
    this.append = false,
  });
}

sealed class StoreReviewsState {}

class StoreReviewsInitial extends StoreReviewsState {}

class StoreReviewsLoading extends StoreReviewsState {}

class StoreReviewsLoaded extends StoreReviewsState {
  final int storeId;
  final List<StoreReviewEntity> items;
  final int page;
  final int pageSize;
  final int total;

  StoreReviewsLoaded({
    required this.storeId,
    required this.items,
    required this.page,
    required this.pageSize,
    required this.total,
  });

  bool get hasMore => items.length < total;
}

class StoreReviewsError extends StoreReviewsState {
  final String message;
  StoreReviewsError(this.message);
}

class StoreReviewsBloc extends Bloc<StoreReviewsEvent, StoreReviewsState> {
  final GetStoreReviewsUseCase getStoreReviewsUseCase;

  StoreReviewsBloc(this.getStoreReviewsUseCase) : super(StoreReviewsInitial()) {
    on<LoadStoreReviews>(_onLoad);
  }

  Future<void> _onLoad(
    LoadStoreReviews event,
    Emitter<StoreReviewsState> emit,
  ) async {
    try {
      if (!event.append) {
        emit(StoreReviewsLoading());
      }

      final result = await getStoreReviewsUseCase(
        storeId: event.storeId,
        page: event.page,
        pageSize: event.pageSize,
      );

      final currentItems = state is StoreReviewsLoaded && event.append
          ? [...(state as StoreReviewsLoaded).items]
          : <StoreReviewEntity>[];

      final mergedItems =
          event.append ? [...currentItems, ...result.items] : result.items;

      emit(StoreReviewsLoaded(
        storeId: event.storeId,
        items: mergedItems,
        page: result.page,
        pageSize: result.pageSize,
        total: result.total,
      ));
    } catch (e) {
      emit(StoreReviewsError(e.toString()));
    }
  }
}
