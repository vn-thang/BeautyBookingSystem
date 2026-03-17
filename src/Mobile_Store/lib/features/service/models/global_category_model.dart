class GlobalCategoryModel {
  final int id;
  final String name;
  final String? iconUrl;
  final bool isActive;
  final int sortOrder;

  GlobalCategoryModel({
    required this.id,
    required this.name,
    this.iconUrl,
    required this.isActive,
    required this.sortOrder,
  });

  factory GlobalCategoryModel.fromJson(Map<String, dynamic> json) {
    return GlobalCategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      iconUrl: json['iconUrl'],
      isActive: json['isActive'] ?? true,
      sortOrder: json['sortOrder'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconUrl': iconUrl,
      'isActive': isActive,
      'sortOrder': sortOrder,
    };
  }
}