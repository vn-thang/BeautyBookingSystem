class FavoriteService {
  final int id;
  final String name;
  final String? imageUrl;
  final double? price;
  final int? storeId;
  final String? storeName;

  FavoriteService({
    required this.id,
    required this.name,
    this.imageUrl,
    this.price,
    this.storeId,
    this.storeName,
  });
}
