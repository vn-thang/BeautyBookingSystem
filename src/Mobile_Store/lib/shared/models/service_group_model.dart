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

factory ServiceGroupModel.fromJson(Map<String, dynamic> json) {
    List<ServiceModel> parsedServices = [];
    
    if (json['services'] != null) {
      for (var item in json['services']) {
        try {
          parsedServices.add(ServiceModel.fromJson(item));
        } catch (e) {
         
          ("❌ LỖI PARSE DỊCH VỤ '${item['name'] ?? 'Không tên'}': $e");
        }
      }
    }
    return ServiceGroupModel(
      id: json['id'] ?? 0,
      storeId: json['storeId'] ?? 0,
      name: json['name'] ?? '',
      sortOrder: json['sortOrder'] ?? 0,
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