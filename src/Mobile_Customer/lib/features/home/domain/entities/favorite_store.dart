class FavoriteStore {
  final int id;
  final String name;
  final String? address;
  final String? logoUrl;
  final String? coverImageUrl;
  final double? averageRating;
  final int? totalReviews;
  final double? distanceKm;

  FavoriteStore({
    required this.id,
    required this.name,
    this.address,
    this.logoUrl,
    this.coverImageUrl,
    this.averageRating,
    this.totalReviews,
    this.distanceKm,
  });
}
