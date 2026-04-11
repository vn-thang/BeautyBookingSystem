import 'operating_hour.dart';

class StoreProfile {
  String name;
  String address;
  String phone;
  String? description;
  String? logoUrl;
  String? coverImageUrl;
  double? latitude;
  double? longitude;
  bool isOpen;
  double averageRating;
  int totalReviews;
  List<OperatingHour> operatingHours;
  int depositPercent; 
  double depositThreshold;
  String? bankName;
  String? bankAccountNumber;
  String? bankAccountName;
  String? zaloPhone;
  String? facebookUrl;

  StoreProfile({
    required this.name,
    required this.address,
    required this.phone,
    this.description,
    this.logoUrl,
    this.coverImageUrl,
    this.latitude,
    this.longitude,
    this.isOpen = false,
    this.averageRating = 0.0,
    this.totalReviews = 0,
    this.depositPercent = 0, 
    this.depositThreshold = 0.0,
    List<OperatingHour>? operatingHours,
    this.bankName,
    this.bankAccountNumber,
    this.bankAccountName,
    this.zaloPhone,
    this.facebookUrl,
  }) : operatingHours = operatingHours ?? [];

  factory StoreProfile.fromJson(Map<String, dynamic> json) {
    var fetchedHours = json['operatingHours'] != null
        ? (json['operatingHours'] as List)
            .map((e) => OperatingHour.fromJson(e as Map<String, dynamic>))
            .toList()
        : <OperatingHour>[];
      

    List<OperatingHour> full7Days = [];
    for (int i = 0; i <= 6; i++) { // 0: CN -> 6: T7
      var existingDay = fetchedHours.where((h) => h.dayOfWeek == i);
      if (existingDay.isNotEmpty) {
       
        var activeDay = existingDay.first;
        activeDay.isActive = true; 
        full7Days.add(activeDay); 
        
      } else {
        full7Days.add(
          OperatingHour(
            dayOfWeek: i, 
            openTime: "08:30", 
            closeTime: "20:30", 
            isActive: false
          )
        );
      }
    }

    return StoreProfile(
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      description: json['description'],
      logoUrl: json['logoUrl'],
      coverImageUrl: json['coverImageUrl'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isOpen: json['isOpen'] ?? false,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0, 
      totalReviews: json['totalReviews'] ?? 0,
      depositPercent: json['depositPercent'] ?? 0,
      depositThreshold: (json['depositThreshold'] as num?)?.toDouble() ?? 0.0,
      operatingHours: full7Days, 
      bankName: json['bankName'],
      bankAccountNumber: json['bankAccountNumber'],
      bankAccountName: json['bankAccountName'],
      zaloPhone: json['zaloPhone'],
      facebookUrl: json['facebookUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'phone': phone,
      'description': description,
      'logoUrl': logoUrl,
      'coverImageUrl': coverImageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'isOpen': isOpen,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'depositPercent': depositPercent,
      'depositThreshold': depositThreshold,
      'operatingHours': operatingHours
          .where((hour) => hour.isActive)
          .map((hour) => hour.toJson())
          .toList(),
      'bankName': bankName,
      'bankAccountNumber': bankAccountNumber,
      'bankAccountName': bankAccountName,
      'zaloPhone': zaloPhone,
      'facebookUrl': facebookUrl,
      
    };
  }
}