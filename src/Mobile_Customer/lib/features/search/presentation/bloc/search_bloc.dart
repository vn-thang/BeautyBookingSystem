import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/location/location_service.dart';
import '../../domain/usecases/search_usecase.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchUseCase searchUseCase;
  final LocationService locationService;

  SearchBloc(this.searchUseCase, this.locationService)
      : super(SearchInitial()) {
    on<SearchLoadInitial>(_onInitial);
    on<SearchRequested>(_onSearch);
  }

  Future<void> _onInitial(
    SearchLoadInitial event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchLoading());

    try {
      final position = await locationService.getCurrentLocation();

      if (position == null) {
        emit(SearchError('Không lấy được vị trí hiện tại'));
        return;
      }

      final result = await searchUseCase(
        keyword: null,
        location: null,
        userLat: position.latitude,
        userLng: position.longitude,
        sortBy: 'nearest',
        minRating: null,
        minPrice: null,
        maxPrice: null,
      );

      emit(SearchLoaded(result, position.latitude, position.longitude));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  Future<void> _onSearch(
    SearchRequested event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchLoading());

    try {
      final position = await locationService.getCurrentLocation();

      if (position == null) {
        emit(SearchError('Không lấy được vị trí hiện tại'));
        return;
      }

      final result = await searchUseCase(
        keyword: event.keyword,
        location: event.location,
        userLat: position.latitude,
        userLng: position.longitude,
        sortBy: event.sortBy,
        minRating: event.minRating,
        minPrice: event.minPrice,
        maxPrice: event.maxPrice,
      );

      emit(SearchLoaded(result, position.latitude, position.longitude));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }
}
