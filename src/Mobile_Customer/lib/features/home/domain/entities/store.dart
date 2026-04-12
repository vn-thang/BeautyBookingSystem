import 'service.dart';
import 'store_banner.dart';

class OperatingHour {
  final int dayOfWeek; // 0 = Sunday ... 6 = Saturday
  final String openTime;
  final String closeTime;

  const OperatingHour({
    required this.dayOfWeek,
    required this.openTime,
    required this.closeTime,
  });
}

class Store {
  final int id;
  final String name;
  final String address;
  final String? phone;
  final String? zaloPhone;
  final String? facebookUrl;
  final String? description;
  final String? logoUrl;
  final String? coverImageUrl;

  final double? latitude;
  final double? longitude;

  final bool? isOpen;
  final double? averageRating;
  final int? totalReviews;

  final int? minServicePrice;
  final double? distanceKm;
  final List<Service> services;
  final List<StoreBanner> banners;
  final List<OperatingHour> operatingHours;

  const Store({
    required this.id,
    required this.name,
    required this.address,
    this.phone,
    this.zaloPhone,
    this.facebookUrl,
    this.description,
    this.logoUrl,
    this.coverImageUrl,
    this.latitude,
    this.longitude,
    this.isOpen,
    this.averageRating,
    this.totalReviews,
    this.minServicePrice,
    this.distanceKm,
    this.services = const [],
    this.banners = const [],
    this.operatingHours = const [],
  });

  Store copyWith({
    double? distanceKm,
    List<OperatingHour>? operatingHours,
    bool? isOpen,
  }) {
    return Store(
      id: id,
      name: name,
      address: address,
      phone: phone,
      zaloPhone: zaloPhone,
      facebookUrl: facebookUrl,
      description: description,
      logoUrl: logoUrl,
      coverImageUrl: coverImageUrl,
      latitude: latitude,
      longitude: longitude,
      isOpen: isOpen ?? this.isOpen,
      averageRating: averageRating,
      totalReviews: totalReviews,
      minServicePrice: minServicePrice,
      distanceKm: distanceKm ?? this.distanceKm,
      services: services,
      banners: banners,
      operatingHours: operatingHours ?? this.operatingHours,
    );
  }
}
