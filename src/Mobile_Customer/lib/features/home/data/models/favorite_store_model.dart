class FavoriteStoreModel {
  final int id;
  final String name;
  final String? address;
  final String? logoUrl;
  final String? coverImageUrl;
  final double? averageRating;
  final int? totalReviews;
  final double? distanceKm;

  FavoriteStoreModel({
    required this.id,
    required this.name,
    this.address,
    this.logoUrl,
    this.coverImageUrl,
    this.averageRating,
    this.totalReviews,
    this.distanceKm,
  });

  factory FavoriteStoreModel.fromJson(Map<String, dynamic> json) {
    return FavoriteStoreModel(
      id: (json['id'] as num).toInt(),
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString(),
      logoUrl: json['logoUrl']?.toString(),
      coverImageUrl: json['coverImageUrl']?.toString(),
      averageRating: (json['averageRating'] as num?)?.toDouble(),
      totalReviews: (json['totalReviews'] as num?)?.toInt(),
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
    );
  }
}
