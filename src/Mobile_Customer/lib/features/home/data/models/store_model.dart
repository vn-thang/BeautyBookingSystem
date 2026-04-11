import '../../domain/entities/store.dart';
import 'service_model.dart';
import 'store_banner_model.dart';

class OperatingHourModel {
  final int dayOfWeek; // 0 = Sunday ... 6 = Saturday
  final String openTime;
  final String closeTime;

  OperatingHourModel({
    required this.dayOfWeek,
    required this.openTime,
    required this.closeTime,
  });

  factory OperatingHourModel.fromJson(Map<String, dynamic> json) {
    return OperatingHourModel(
      dayOfWeek: _parseInt(json['dayOfWeek']) ?? 0,
      openTime: json['openTime'] ?? '',
      closeTime: json['closeTime'] ?? '',
    );
  }

  OperatingHour toEntity() {
    return OperatingHour(
      dayOfWeek: dayOfWeek,
      openTime: openTime,
      closeTime: closeTime,
    );
  }

  static int? _parseInt(dynamic x) {
    if (x == null) return null;
    if (x is int) return x;
    if (x is double) return x.toInt();
    return int.tryParse(x.toString());
  }
}

class StoreModel {
  final int id;
  final String name;
  final String address;
  final String? phone;
  final String? description;
  final String? logoUrl;
  final String? coverImageUrl;
  final double? latitude;
  final double? longitude;
  final double? distanceKm;
  final bool? isOpen;
  final bool isFavorite;
  final double? averageRating;
  final int? totalReviews;
  final int? minServicePrice;
  final List<ServiceModel> services;
  final List<StoreBannerModel> banners;
  final List<OperatingHourModel> operatingHours;

  StoreModel({
    required this.id,
    required this.name,
    required this.address,
    this.phone,
    this.description,
    this.logoUrl,
    this.coverImageUrl,
    this.latitude,
    this.longitude,
    this.distanceKm,
    this.isOpen,
    required this.isFavorite,
    this.averageRating,
    this.totalReviews,
    this.minServicePrice,
    this.services = const [],
    this.banners = const [],
    this.operatingHours = const [],
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    double? parseDouble(dynamic x) {
      if (x == null) return null;
      if (x is num) return x.toDouble();
      return double.tryParse(x.toString());
    }

    int? parseInt(dynamic x) {
      if (x == null) return null;
      if (x is int) return x;
      if (x is double) return x.toInt();
      return int.tryParse(x.toString());
    }

    return StoreModel(
      id: parseInt(json['id']) ?? 0,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'],
      description: json['description'],
      logoUrl: json['logoUrl'],
      coverImageUrl: json['coverImageUrl'],
      latitude: parseDouble(json['latitude']),
      longitude: parseDouble(json['longitude']),
      distanceKm: parseDouble(json['distanceKm']),
      isOpen: json['isOpen'] as bool?,
      isFavorite: json['isFavorite'] as bool? ?? false,
      averageRating: parseDouble(json['averageRating']),
      totalReviews: parseInt(json['totalReviews']),
      minServicePrice: parseInt(json['minServicePrice']),
      services: (json['services'] as List<dynamic>? ?? [])
          .map((e) => ServiceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      banners: (json['banners'] as List<dynamic>? ?? [])
          .map((e) => StoreBannerModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      operatingHours: (json['operatingHours'] as List<dynamic>? ?? [])
          .map((e) => OperatingHourModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Store toEntity() {
    return Store(
      id: id,
      name: name,
      address: address,
      phone: phone,
      description: description,
      logoUrl: logoUrl,
      coverImageUrl: coverImageUrl,
      latitude: latitude,
      longitude: longitude,
      distanceKm: distanceKm,
      isOpen: isOpen,
      averageRating: averageRating,
      totalReviews: totalReviews,
      minServicePrice: minServicePrice,
      services: services.map((e) => e.toEntity()).toList(),
      banners: banners.map((e) => e.toEntity()).toList(),
      operatingHours: operatingHours.map((e) => e.toEntity()).toList(),
    );
  }
}
