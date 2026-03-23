import '../../domain/entities/store_banner.dart';

class StoreBannerModel {
  final int id;

  final String imageUrl;
  final String? title;
  final String? description;

  final int sortOrder;
  final bool isActive;

  StoreBannerModel({
    required this.id,
    required this.imageUrl,
    this.title,
    this.description,
    required this.sortOrder,
    required this.isActive,
  });

  factory StoreBannerModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic x) {
      if (x == null) return 0;
      if (x is int) return x;
      if (x is double) return x.toInt();
      return int.tryParse(x.toString()) ?? 0;
    }

    bool parseBool(dynamic x) {
      if (x == null) return false;
      if (x is bool) return x;
      if (x is int) return x == 1;
      return x.toString().toLowerCase() == 'true';
    }

    return StoreBannerModel(
      id: parseInt(json['id']),
      imageUrl: json['imageUrl']?.toString() ?? '',
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      sortOrder: parseInt(json['sortOrder']),
      isActive: parseBool(json['isActive']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'imageUrl': imageUrl,
        'title': title,
        'description': description,
        'sortOrder': sortOrder,
        'isActive': isActive,
      };

  StoreBanner toEntity() {
    return StoreBanner(
      id: id,
      imageUrl: imageUrl,
      title: title,
      description: description,
      sortOrder: sortOrder,
      isActive: isActive,
    );
  }
}
