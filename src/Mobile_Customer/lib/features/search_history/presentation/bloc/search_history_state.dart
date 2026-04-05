import 'package:equatable/equatable.dart';
import '../../domain/entities/search_history_entity.dart';

abstract class SearchHistoryState extends Equatable {
  const SearchHistoryState();

  @override
  List<Object?> get props => [];
}

class SearchHistoryInitial extends SearchHistoryState {}

class SearchHistoryLoading extends SearchHistoryState {}

class SearchHistoryLoaded extends SearchHistoryState {
  final List<SearchHistoryEntity> items;
  final String query;

  const SearchHistoryLoaded({
    required this.items,
    this.query = '',
  });

  List<SearchHistoryEntity> get filteredItems {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return items;

    return items
        .where((e) => e.keyword.toLowerCase().contains(q))
        .toList();
  }

  @override
  List<Object?> get props => [items, query];
}

class SearchHistoryFailure extends SearchHistoryState {
  final String message;

  const SearchHistoryFailure(this.message);

  @override
  List<Object?> get props => [message];
}