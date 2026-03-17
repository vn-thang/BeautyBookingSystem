class ServiceModel {
  final int id;
  final int categoryId;
  final int? groupId;
  final String name;
  final double price;
  final int durationMinutes; 
  final String? description;
  final String? imageUrl;
  final bool isActive;

  ServiceModel({
    required this.id,
    required this.categoryId,
    this.groupId,
    required this.name,
    this.price = 0.0,
    this.durationMinutes = 0,
    this.description,
    this.imageUrl,
    this.isActive = true,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] ?? 0,
      categoryId: json['categoryId'] ?? 0,
      groupId: json['groupId'], 
      name: json['name'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      durationMinutes: json['durationMinutes'] ?? 0,
      description: json['description'],
      imageUrl: json['imageUrl'],
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'groupId': groupId,
      'name': name,
      'price': price,
      'durationMinutes': durationMinutes,
      'description': description,
      'imageUrl': imageUrl,
      'isActive': isActive,
    };
  }
}