import '../../domain/entities/global_category.dart';

class GlobalCategoryModel {
  final int id;
  final String name;
  final String iconUrl;

  GlobalCategoryModel({
    required this.id,
    required this.name,
    required this.iconUrl,
  });

  factory GlobalCategoryModel.fromJson(Map<String, dynamic> json) {
    return GlobalCategoryModel(
      id: json['id'],
      name: json['name'],
      iconUrl: json['iconUrl'] ?? '',
    );
  }

  GlobalCategory toEntity() {
    return GlobalCategory(
      id: id,
      name: name,
      iconUrl: iconUrl,
    );
  }
}