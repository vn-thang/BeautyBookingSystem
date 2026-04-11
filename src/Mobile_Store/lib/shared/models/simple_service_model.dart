// simple_service_model.dart
class SimpleServiceModel {
  final int id;
  final String name;

  SimpleServiceModel({
    required this.id,
    required this.name,
  });

  factory SimpleServiceModel.fromJson(Map<String, dynamic> json) {
    return SimpleServiceModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}