import '../../domain/entities/store.dart';

class StoreModel {
  final int id;
  final String name;
  final String address;
  final String? logoUrl;
  final double latitude;
  final double longitude;
  double? distanceKm;

  StoreModel({
    required this.id,
    required this.name,
    required this.address,
    this.logoUrl,
    required this.latitude,
    required this.longitude,
    this.distanceKm,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'] as int,
      name: json['name'] as String,
      address: json['address'] as String? ?? '',
      logoUrl: json['logoUrl'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Store toEntity() {
    return Store(
      id: id,
      name: name,
      address: address,
      logoUrl: logoUrl,
      latitude: latitude,
      longitude: longitude,
      distanceKm: distanceKm,
    );
  }
}