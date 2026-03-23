abstract class SearchEvent {}

class SearchLoadInitial extends SearchEvent {}

class SearchRequested extends SearchEvent {
  final String? keyword;
  final String? location;
  final String sortBy;
  final int? minRating;
  final double? minPrice;
  final double? maxPrice;

  SearchRequested({
    this.keyword,
    this.location,
    required this.sortBy,
    this.minRating,
    this.minPrice,
    this.maxPrice,
  });
}
