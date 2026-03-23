// lib/features/home/data/models/store_list_response.dart
import 'store_model.dart';

class StoreListResponse {
  final int page;
  final int pageSize;
  final int total;
  final List<StoreModel> items;

  StoreListResponse({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.items,
  });

  factory StoreListResponse.fromJson(Map<String, dynamic> json) {
    final parseItems = <StoreModel>[];
    final rawItems = json['items'];
    if (rawItems is List) {
      for (var e in rawItems) {
        parseItems.add(StoreModel.fromJson(Map<String, dynamic>.from(e)));
      }
    }
    return StoreListResponse(
      page: (json['page'] is int) ? json['page'] as int : int.tryParse('${json['page']}') ?? 1,
      pageSize: (json['pageSize'] is int) ? json['pageSize'] as int : int.tryParse('${json['pageSize']}') ?? parseItems.length,
      total: (json['total'] is int) ? json['total'] as int : int.tryParse('${json['total']}') ?? parseItems.length,
      items: parseItems,
    );
  }
}