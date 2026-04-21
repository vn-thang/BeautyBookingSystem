class StoreBannerModel {
  final int id;
  final String imageUrl;
  final String? title;
  final String? description;
  final int sortOrder;
  bool isActive;

  StoreBannerModel({
    required this.id,
    required this.imageUrl,
    this.title,
    this.description,
    required this.sortOrder,
    required this.isActive,
  });

  factory StoreBannerModel.fromJson(Map<String, dynamic> json) {
    return StoreBannerModel(
      id: json['id'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
      title: json['title'],
      description: json['description'],
      sortOrder: json['sortOrder'] ?? 0,
      isActive: json['isActive'] ?? false,
    );
  }
}