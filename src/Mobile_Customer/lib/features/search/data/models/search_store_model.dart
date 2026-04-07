import '../../domain/entities/search_service.dart';
import '../../domain/entities/search_store.dart';

class SearchServiceModel {
  final int id;
  final String name;
  final double price;

  SearchServiceModel({
    required this.id,
    required this.name,
    required this.price,
  });

  factory SearchServiceModel.fromJson(Map<String, dynamic> json) {
    return SearchServiceModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
    );
  }

  SearchService toEntity() {
    return SearchService(
      id: id,
      name: name,
      price: price,
    );
  }
}

class SearchStoreModel {
  final int id;
  final String name;
  final String address;
  final String? imageUrl;
  final double rating;
  final double distanceKm;
  final double? lat;
  final double? lng;
  final double minPrice;
  final List<SearchServiceModel> services;

  SearchStoreModel({
    required this.id,
    required this.name,
    required this.address,
    this.imageUrl,
    required this.rating,
    required this.distanceKm,
    this.lat,
    this.lng,
    required this.minPrice,
    required this.services,
  });

  factory SearchStoreModel.fromJson(Map<String, dynamic> json) {
    return SearchStoreModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0,
      lat: json['lat'] == null ? null : (json['lat'] as num).toDouble(),
      lng: json['lng'] == null ? null : (json['lng'] as num).toDouble(),
      minPrice: (json['minServicePrice'] as num?)?.toDouble() ?? 0,
      services: (json['services'] as List<dynamic>? ?? [])
          .map((e) => SearchServiceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  SearchStore toEntity() {
    return SearchStore(
      id: id,
      name: name,
      address: address,
      imageUrl: imageUrl,
      rating: rating,
      distanceKm: distanceKm,
      lat: lat,
      lng: lng,
      minPrice: minPrice,
      services: services.map((e) => e.toEntity()).toList(),
    );
  }
}
