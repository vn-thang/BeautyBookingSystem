import 'service.dart';
import 'store_banner.dart';

class Store {
  final int id;
  final String name;
  final String address;
  final String? phone;
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

  const Store({
    required this.id,
    required this.name,
    required this.address,
    this.phone,
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
  });
  Store copyWith({
    double? distanceKm,
  }) {
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
      isOpen: isOpen,
      averageRating: averageRating,
      totalReviews: totalReviews,
      minServicePrice: minServicePrice,
      distanceKm: distanceKm ?? this.distanceKm,
      services: services,
      banners: banners,
    );
  }
}
