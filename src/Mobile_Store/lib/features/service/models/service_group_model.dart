import 'service_model.dart';

class ServiceGroupModel {
  final int id;
  final int storeId;
  final String name;
  final int sortOrder;
  List<ServiceModel> services;

  ServiceGroupModel({
    required this.id,
    required this.storeId,
    required this.name,
    required this.sortOrder,
    this.services = const [],
  });

  // factory ServiceGroupModel.fromJson(Map<String, dynamic> json) {
  //    List<ServiceModel> parsedServices = [];
    
  //   // 🟢 Bọc try-catch từng dịch vụ để xem cái nào làm crash app
  //   if (json['services'] != null) {
  //     for (var item in json['services']) {
  //       try {
  //         parsedServices.add(ServiceModel.fromJson(item));
  //       } catch (e) {
  //         // NẾU CÓ LỖI, NÓ SẼ IN RA TẠI ĐÂY:
  //         print("❌ LỖI PARSE DỊCH VỤ '${item['name'] ?? 'Không tên'}': $e");
  //       }
  //     }
  //   }
  //   return ServiceGroupModel(
  //     id: json['id'] ?? 0,
  //     storeId: json['storeId'] ?? 0,
  //     name: json['name'] ?? '',
  //     sortOrder: json['sortOrder'] ?? 0,
  //     // Parse an toàn danh sách dịch vụ con nếu Backend có trả về
  //     services: json['services'] != null
  //         ? (json['services'] as List).map((i) => ServiceModel.fromJson(i)).toList()
  //         : [],
  //   );
  // }

factory ServiceGroupModel.fromJson(Map<String, dynamic> json) {
    List<ServiceModel> parsedServices = [];
    
    // 🟢 Bọc try-catch từng dịch vụ để xem cái nào làm crash app
    if (json['services'] != null) {
      for (var item in json['services']) {
        try {
          parsedServices.add(ServiceModel.fromJson(item));
        } catch (e) {
          // ❌ NẾU CÓ LỖI, NÓ SẼ IN RA TẠI ĐÂY:
          ("❌ LỖI PARSE DỊCH VỤ '${item['name'] ?? 'Không tên'}': $e");
        }
      }
    }
     ("✅ Đã tóm được ${parsedServices.length} dịch vụ cho Nhóm ${json['id']}");
    return ServiceGroupModel(
      id: json['id'] ?? 0,
      storeId: json['storeId'] ?? 0,
      name: json['name'] ?? '',
      sortOrder: json['sortOrder'] ?? 0,
      // 🔥 SỬA Ở ĐÂY: Truyền thẳng danh sách đã lọc lỗi an toàn vào
      services: parsedServices, 
    );
  }

  Map<String, dynamic> toJson() {
   
    return {
      'id': id,
      'storeId': storeId,
      'name': name,
      'sortOrder': sortOrder,
      'services': services.map((x) => x.toJson()).toList(),
    };
  }
}