class Service {
  final int id;

  final int storeId;
  final int categoryId;
  final int? groupId;

  final String name;
  final String? description;
  final String? imageUrl;

  final double price;
  final int durationMinutes;

  final bool isActive;
  final bool isFeatured;
  final int sortOrder;

  Service({
    required this.id,
    required this.storeId,
    required this.categoryId,
    this.groupId,
    required this.name,
    this.description,
    this.imageUrl,
    required this.price,
    required this.durationMinutes,
    required this.isActive,
    required this.isFeatured,
    required this.sortOrder,
  });
}