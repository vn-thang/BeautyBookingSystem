import '../../domain/entities/search_store.dart';

abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<SearchStore> stores;
  final double userLat;
  final double userLng;

  SearchLoaded(
    this.stores,
    this.userLat,
    this.userLng,
  );
}

class SearchError extends SearchState {
  final String message;

  SearchError(this.message);
}
