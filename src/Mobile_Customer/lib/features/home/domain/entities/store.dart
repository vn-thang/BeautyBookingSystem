class Store {
  final int id;
  final String name;
  final String address;
  final String? logoUrl;
  final double latitude;
  final double longitude;
  final double? distanceKm;

  Store({
    required this.id,
    required this.name,
    required this.address,
    this.logoUrl,
    required this.latitude,
    required this.longitude,
    this.distanceKm,
  });

  Store copyWith({
    double? distanceKm,
  }) {
    return Store(
      id: id,
      name: name,
      address: address,
      logoUrl: logoUrl,
      latitude: latitude,
      longitude: longitude,
      distanceKm: distanceKm ?? this.distanceKm,
    );
  }
}