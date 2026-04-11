import 'package:equatable/equatable.dart';

abstract class SearchHistoryEvent extends Equatable {
  const SearchHistoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadRecentSearchHistories extends SearchHistoryEvent {
  const LoadRecentSearchHistories();
}

class RecordSearchHistoryRequested extends SearchHistoryEvent {
  final String keyword;

  const RecordSearchHistoryRequested(this.keyword);

  @override
  List<Object?> get props => [keyword];
}

class DeleteSearchHistoryRequested extends SearchHistoryEvent {
  final int id;

  const DeleteSearchHistoryRequested(this.id);

  @override
  List<Object?> get props => [id];
}

class FilterSearchHistoriesRequested extends SearchHistoryEvent {
  final String query;

  const FilterSearchHistoriesRequested(this.query);

  @override
  List<Object?> get props => [query];
}
