import '../../domain/entities/service_group.dart';

class ServiceGroupModel {
  final int id;
  final String name;

  ServiceGroupModel({
    required this.id,
    required this.name,
  });

  factory ServiceGroupModel.fromJson(Map<String, dynamic> json) {
    return ServiceGroupModel(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  ServiceGroup toEntity() {
    return ServiceGroup(
      id: id,
      name: name,
    );
  }
}