import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../models/global_category_model.dart';
import '../../../shared/models/service_group_model.dart';

class ServiceApi {
  static Future<List<GlobalCategoryModel>> getGlobalCategories() async {
    final json = await ApiClient.get('/api/AdminCategories');
    List data = json is List ? json : (json['data'] ?? []);
    return data.map((e) => GlobalCategoryModel.fromJson(e)).toList();
  }

  static Future<List<ServiceGroupModel>> getGroupedServices(int storeId) async {
    final json = await ApiClient.get('/api/StoreServiceGroups?storeId=$storeId');
    List data = json is List ? json : (json['data'] ?? []);
    
    List<ServiceGroupModel> groups = data.map((e) => ServiceGroupModel.fromJson(e)).toList();
    groups.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return groups;
  }

  static Future<void> createServiceGroup({required int storeId, required String name}) async {
    await ApiClient.post('/api/StoreServiceGroups', body: {
      'storeId': storeId, 'name': name, 'sortOrder': 0,
    });
  }

  static Future<void> updateServiceGroup({
    required int groupId, required int storeId, required String name, required int sortOrder,
  }) async {
    await ApiClient.put('/api/StoreServiceGroups/$groupId', body: {
      'id': groupId, 'storeId': storeId, 'name': name, 'sortOrder': sortOrder,
    });
  }

  static Future<void> deleteServiceGroup(int groupId) async {
    await ApiClient.delete('/api/StoreServiceGroups/$groupId');
  }

  static Future<void> createService({
    required int storeId, required int categoryId, int? groupId,    
    required String name, required double price, required int durationMinutes, 
    String? description, String? imageUrl,
  }) async {
    await ApiClient.post('/api/StoreServices', body: {
      "storeId": storeId, "categoryId": categoryId, 
      "groupId": (groupId == 0) ? null : groupId,
      "name": name,
      "description": (description?.trim().isEmpty ?? true) ? null : description, 
      "imageUrl": (imageUrl?.trim().isEmpty ?? true) ? null : imageUrl, 
      "price": price, "durationMinutes": durationMinutes, 
      "isActive": true, "isFeatured": false, "sortOrder": 0
    });
  }

  static Future<void> updateService({
    required int serviceId, required int storeId, required int categoryId, int? groupId, 
    required String name, required double price, required int durationMinutes,
    String? description, String? imageUrl, required bool isActive,
  }) async {
    await ApiClient.put('/api/StoreServices/$serviceId', body: {
      "id": serviceId, "storeId": storeId, "categoryId": categoryId,
      "groupId": (groupId == 0) ? null : groupId,
      "name": name,
      "description": (description?.trim().isEmpty ?? true) ? null : description,
      "imageUrl": (imageUrl?.trim().isEmpty ?? true) ? null : imageUrl,
      "price": price, "durationMinutes": durationMinutes,
      "isActive": isActive, "isFeatured": false, "sortOrder": 0
    });
  }

  static Future<void> deleteService(int serviceId) async {
    await ApiClient.delete('/api/StoreServices/$serviceId');
  }
}