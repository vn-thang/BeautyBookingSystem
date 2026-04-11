import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/delete_search_history.dart';
import '../../domain/usecases/get_recent_search_histories.dart';
import '../../domain/usecases/record_search_history.dart';
import 'search_history_event.dart';
import 'search_history_state.dart';

class SearchHistoryBloc extends Bloc<SearchHistoryEvent, SearchHistoryState> {
  final GetRecentSearchHistories getRecentSearchHistories;
  final RecordSearchHistory recordSearchHistory;
  final DeleteSearchHistory deleteSearchHistory;

  SearchHistoryBloc({
    required this.getRecentSearchHistories,
    required this.recordSearchHistory,
    required this.deleteSearchHistory,
  }) : super(SearchHistoryInitial()) {
    on<LoadRecentSearchHistories>(_onLoad);
    on<RecordSearchHistoryRequested>(_onRecord);
    on<DeleteSearchHistoryRequested>(_onDelete);
    on<FilterSearchHistoriesRequested>(_onFilter);
  }

  Future<void> _onLoad(
    LoadRecentSearchHistories event,
    Emitter<SearchHistoryState> emit,
  ) async {
    try {
      emit(SearchHistoryLoading());
      final items = await getRecentSearchHistories();
      emit(SearchHistoryLoaded(items: items));
    } catch (e) {
      emit(SearchHistoryFailure(e.toString()));
    }
  }

  Future<void> _onRecord(
    RecordSearchHistoryRequested event,
    Emitter<SearchHistoryState> emit,
  ) async {
    final current = state is SearchHistoryLoaded
        ? (state as SearchHistoryLoaded).items
        : <dynamic>[];

    try {
      final normalized = event.keyword.trim();
      if (normalized.isEmpty) return;

      final items = await recordSearchHistory(normalized);
      emit(SearchHistoryLoaded(items: items));
    } catch (e) {
      emit(SearchHistoryFailure(e.toString()));
      if (current.isNotEmpty) {
        emit(SearchHistoryLoaded(items: current.cast()));
      }
    }
  }

  Future<void> _onDelete(
    DeleteSearchHistoryRequested event,
    Emitter<SearchHistoryState> emit,
  ) async {
    try {
      final items = await deleteSearchHistory(event.id);
      emit(SearchHistoryLoaded(items: items));
    } catch (e) {
      emit(SearchHistoryFailure(e.toString()));
    }
  }

  void _onFilter(
    FilterSearchHistoriesRequested event,
    Emitter<SearchHistoryState> emit,
  ) {
    if (state is! SearchHistoryLoaded) return;

    final current = state as SearchHistoryLoaded;
    emit(SearchHistoryLoaded(items: current.items, query: event.query));
  }
}