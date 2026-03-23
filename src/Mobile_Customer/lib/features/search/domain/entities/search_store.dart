import 'search_service.dart';

class SearchStore {
  final int id;
  final String name;
  final String address;
  final String? imageUrl;
  final double rating;
  final double distanceKm;
  final double? lat;
  final double? lng;
  final double minPrice;
  final List<SearchService> services;

  const SearchStore({
    required this.id,
    required this.name,
    required this.address,
    this.imageUrl,
    required this.rating,
    required this.distanceKm,
    this.lat,
    this.lng,
    required this.minPrice,
    required this.services,
  });
}
