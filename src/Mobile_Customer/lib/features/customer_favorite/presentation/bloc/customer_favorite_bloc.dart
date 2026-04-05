import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/favorite_service_usecase.dart';
import '../../domain/usecases/favorite_store_usecase.dart';
import '../../domain/usecases/unfavorite_service_usecase.dart';
import '../../domain/usecases/unfavorite_store_usecase.dart';

enum CustomerFavoriteType { store, service }

abstract class CustomerFavoriteEvent {}

class CustomerFavoriteFavoritePressed extends CustomerFavoriteEvent {}

class CustomerFavoriteUnfavoritePressed extends CustomerFavoriteEvent {}

class CustomerFavoriteState {
  final bool isFavorite;
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const CustomerFavoriteState({
    required this.isFavorite,
    required this.isLoading,
    this.error,
    this.successMessage,
  });

  factory CustomerFavoriteState.initial({bool isFavorite = false}) {
    return CustomerFavoriteState(
      isFavorite: isFavorite,
      isLoading: false,
    );
  }

  CustomerFavoriteState copyWith({
    bool? isFavorite,
    bool? isLoading,
    String? error,
    String? successMessage,
  }) {
    return CustomerFavoriteState(
      isFavorite: isFavorite ?? this.isFavorite,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
    );
  }
}

class CustomerFavoriteBloc
    extends Bloc<CustomerFavoriteEvent, CustomerFavoriteState> {
  final CustomerFavoriteType type;
  final int targetId;

  final FavoriteStoreUseCase favoriteStoreUseCase;
  final UnfavoriteStoreUseCase unfavoriteStoreUseCase;
  final FavoriteServiceUseCase favoriteServiceUseCase;
  final UnfavoriteServiceUseCase unfavoriteServiceUseCase;

  CustomerFavoriteBloc({
    required this.type,
    required this.targetId,
    required this.favoriteStoreUseCase,
    required this.unfavoriteStoreUseCase,
    required this.favoriteServiceUseCase,
    required this.unfavoriteServiceUseCase,
    bool initialIsFavorite = false,
  }) : super(CustomerFavoriteState.initial(isFavorite: initialIsFavorite)) {
    on<CustomerFavoriteFavoritePressed>((event, emit) async {
      if (state.isLoading) return;

      emit(state.copyWith(isLoading: true, error: null));

      try {
        if (type == CustomerFavoriteType.store) {
          await favoriteStoreUseCase(targetId);
        } else {
          await favoriteServiceUseCase(targetId);
        }

        emit(state.copyWith(
          isFavorite: true,
          isLoading: false,
          successMessage: 'Đã thêm vào yêu thích ❤️',
        ));
      } catch (e) {
        String message = "Có lỗi xảy ra";

        if (e is DioException) {
          if (e.response?.statusCode == 401) {
            message = "Bạn cần đăng nhập để thực hiện chức năng này";
          } else if (e.response?.statusCode == 500) {
            message = "Server đang lỗi, vui lòng thử lại sau";
          } else {
            message = "Không thể thực hiện, vui lòng thử lại";
          }
        }

        emit(state.copyWith(
          isLoading: false,
          error: message,
        ));
      }
    });

    on<CustomerFavoriteUnfavoritePressed>((event, emit) async {
      if (state.isLoading) return;

      emit(state.copyWith(isLoading: true, error: null));

      try {
        if (type == CustomerFavoriteType.store) {
          await unfavoriteStoreUseCase(targetId);
        } else {
          await unfavoriteServiceUseCase(targetId);
        }

        emit(state.copyWith(
          isFavorite: false,
          isLoading: false,
          successMessage: 'Đã bỏ khỏi yêu thích 💔',
        ));
      } catch (e) {
        emit(state.copyWith(
          isLoading: false,
          error: e.toString(),
          successMessage: null,
        ));
      }
    });
  }
}
