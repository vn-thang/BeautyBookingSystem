class FavoriteServiceModel {
  final int id;
  final int? storeId;
  final String? storeName;
  final String name;
  final String? imageUrl;
  final double? price;
  final int? durationMinutes;

  FavoriteServiceModel({
    required this.id,
    required this.name,
    this.storeId,
    this.storeName,
    this.imageUrl,
    this.price,
    this.durationMinutes,
  });

  factory FavoriteServiceModel.fromJson(Map<String, dynamic> json) {
    return FavoriteServiceModel(
      id: (json['id'] as num).toInt(),
      storeId: (json['storeId'] as num?)?.toInt(),
      storeName: json['storeName']?.toString(),
      name: json['name']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
      price: (json['price'] as num?)?.toDouble(),
      durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
    );
  }
}
