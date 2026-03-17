// // file: lib/models/store_profile.dart

// import 'operating_hour.dart';

// class StoreProfile {
//   String name;
//   String address;
//   String phone;
//   String? description;
//   String? logoUrl;
//   String? coverImageUrl;
//   double? latitude;
//   double? longitude;
//   bool isOpen;
//   double averageRating;
//   int totalReviews;
//   List<OperatingHour> operatingHours;

//   StoreProfile({
//     required this.name,
//     required this.address,
//     required this.phone,
//     this.description,
//     this.logoUrl,
//     this.coverImageUrl,
//     this.latitude,
//     this.longitude,
//     this.isOpen = false,
//     this.averageRating = 0.0,
//     this.totalReviews = 0,
//     List<OperatingHour>? operatingHours,
//   }) : operatingHours = operatingHours ?? [];

//   // Parse từ JSON backend trả về
//   factory StoreProfile.fromJson(Map<String, dynamic> json) {
//     // 1. Lấy danh sách giờ mà API trả về (những ngày đang active)
//     var fetchedHours = json['operatingHours'] != null
//         ? (json['operatingHours'] as List)
//             .map((e) => OperatingHour.fromJson(e as Map<String, dynamic>))
//             .toList()
//         : <OperatingHour>[];
//         print("====== SỐ NGÀY LẤY TỪ API: ${fetchedHours.length} ======");

//     // 2. Tự động lấp đầy đủ 7 ngày (Ngày nào API không trả về nghĩa là đang Nghỉ)
//     List<OperatingHour> full7Days = [];
//     for (int i = 0; i <= 6; i++) { // 0: CN -> 6: T7
//       var existingDay = fetchedHours.where((h) => h.dayOfWeek == i);
//       if (existingDay.isNotEmpty) {
//         // Ngày có hoạt động (API có trả về)
//         full7Days.add(existingDay.first); 
        
//       } else {
//         // Ngày nghỉ -> Đặt isActive: false và gắn giờ mặc định
//         full7Days.add(
//           OperatingHour(
//             dayOfWeek: i, 
//             openTime: "08:00", 
//             closeTime: "20:00", 
//             isActive: false
//           )
//         );
//       }
//     }

//     return StoreProfile(
//       name: json['name'] ?? '',
//       address: json['address'] ?? '',
//       phone: json['phone'] ?? '',
//       description: json['description'],
//       logoUrl: json['logoUrl'],
//       coverImageUrl: json['coverImageUrl'],
//       latitude: (json['latitude'] as num?)?.toDouble(),
//       longitude: (json['longitude'] as num?)?.toDouble(),
//       isOpen: json['isOpen'] ?? false,
//       averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0, // Ép từ decimal sang double
//       totalReviews: json['totalReviews'] ?? 0,
//       operatingHours: full7Days, // Đưa danh sách đủ 7 ngày vào đây
//     );
//   }

//   // Đóng gói JSON gửi lên C# Backend (khớp với StoreProfileDto)
//   Map<String, dynamic> toJson() {
//     return {
//       'name': name,
//       'address': address,
//       'phone': phone,
//       'description': description,
//       'logoUrl': logoUrl,
//       'coverImageUrl': coverImageUrl,
//       'latitude': latitude,
//       'longitude': longitude,
//       'isOpen': isOpen,
//       'averageRating': averageRating,
//       'totalReviews': totalReviews,
//       // Lọc: Chỉ gửi những ngày được chọn (isActive = true) và gọi hàm toJson() của OperatingHour
//       'operatingHours': operatingHours
//           .where((hour) => hour.isActive)
//           .map((hour) => hour.toJson())
//           .toList(),
//     };
//   }
// }

// file: lib/models/store_profile.dart

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
    List<OperatingHour>? operatingHours,
  }) : operatingHours = operatingHours ?? [];

  // Parse từ JSON backend trả về
  factory StoreProfile.fromJson(Map<String, dynamic> json) {
    // 1. Lấy danh sách giờ mà API trả về (những ngày đang active)
    var fetchedHours = json['operatingHours'] != null
        ? (json['operatingHours'] as List)
            .map((e) => OperatingHour.fromJson(e as Map<String, dynamic>))
            .toList()
        : <OperatingHour>[];
      

    // 2. Tự động lấp đầy đủ 7 ngày (Ngày nào API không trả về nghĩa là đang Nghỉ)
    List<OperatingHour> full7Days = [];
    for (int i = 0; i <= 6; i++) { // 0: CN -> 6: T7
      var existingDay = fetchedHours.where((h) => h.dayOfWeek == i);
      if (existingDay.isNotEmpty) {
        // Ngày có hoạt động (API có trả về) -> Bắt buộc gán isActive = true
        var activeDay = existingDay.first;
        activeDay.isActive = true; 
        full7Days.add(activeDay); 
        
      } else {
        // Ngày nghỉ -> Đặt isActive: false và gắn giờ mặc định (khớp với ảnh UI của bạn)
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
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0, // Ép từ decimal sang double
      totalReviews: json['totalReviews'] ?? 0,
      operatingHours: full7Days, // Đưa danh sách đủ 7 ngày vào đây
    );
  }

  // Đóng gói JSON gửi lên C# Backend (khớp với StoreProfileDto)
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
      // Lọc: Chỉ gửi những ngày được chọn (isActive = true) và gọi hàm toJson() của OperatingHour
      'operatingHours': operatingHours
          .where((hour) => hour.isActive)
          .map((hour) => hour.toJson())
          .toList(),
    };
  }
}