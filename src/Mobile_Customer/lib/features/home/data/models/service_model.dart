import '../../domain/entities/service.dart';

class ServiceModel {
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

  ServiceModel({
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

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic x) {
      if (x == null) return 0;
      if (x is int) return x;
      if (x is double) return x.toInt();
      return int.tryParse(x.toString()) ?? 0;
    }

    double parseDouble(dynamic x) {
      if (x == null) return 0;
      if (x is double) return x;
      if (x is int) return x.toDouble();
      return double.tryParse(x.toString()) ?? 0;
    }

    bool parseBool(dynamic x) {
      if (x == null) return false;
      if (x is bool) return x;
      if (x is int) return x == 1;
      return x.toString().toLowerCase() == 'true';
    }

    return ServiceModel(
      id: parseInt(json['id']),
      storeId: parseInt(json['storeId']),
      categoryId: parseInt(json['categoryId']),
      groupId: json['groupId'] != null
          ? parseInt(json['groupId'])
          : null,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
      price: parseDouble(json['price']),
      durationMinutes: parseInt(json['durationMinutes']),
      isActive: parseBool(json['isActive']),
      isFeatured: parseBool(json['isFeatured']),
      sortOrder: parseInt(json['sortOrder']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'storeId': storeId,
        'categoryId': categoryId,
        'groupId': groupId,
        'name': name,
        'description': description,
        'imageUrl': imageUrl,
        'price': price,
        'durationMinutes': durationMinutes,
        'isActive': isActive,
        'isFeatured': isFeatured,
        'sortOrder': sortOrder,
      };

  Service toEntity() {
    return Service(
      id: id,
      storeId: storeId,
      categoryId: categoryId,
      groupId: groupId,
      name: name,
      description: description,
      imageUrl: imageUrl,
      price: price,
      durationMinutes: durationMinutes,
      isActive: isActive,
      isFeatured: isFeatured,
      sortOrder: sortOrder,
    );
  }
}