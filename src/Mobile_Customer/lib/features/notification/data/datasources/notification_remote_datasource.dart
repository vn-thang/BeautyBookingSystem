import 'package:dio/dio.dart';
import '../models/notification_model.dart';

class NotificationRemoteDataSource {
  final Dio dio;

  NotificationRemoteDataSource(this.dio);

  Future<List<NotificationModel>> getNotifications(int pageIndex, int pageSize) async {
    final resp = await dio.get(
      'notifications',
      queryParameters: {
        'pageIndex': pageIndex,
        'pageSize': pageSize,
      },
    );

    final data = resp.data;
    final List items = data is List
        ? data
        : (data is Map && data['data'] is List)
            ? data['data']
            : <dynamic>[];

    return items
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<int> getUnreadCount() async {
    final resp = await dio.get('notifications/unread-count');
    
    // Kiểm tra xem backend trả về Map {"count": X} hay trả thẳng về số X
    if (resp.data is Map<String, dynamic>) {
      // Lấy value từ key 'count'
      return (resp.data['count'] as num?)?.toInt() ?? 0;
    } else {
      // Đề phòng trường hợp backend trả về trực tiếp số
      return (resp.data as num?)?.toInt() ?? 0;
    }
  }

  Future<bool> markAsRead(int id) async {
    final resp = await dio.put('notifications/$id/read');
    return resp.statusCode == 200 || resp.statusCode == 204;
  }

  Future<bool> markAllAsRead() async {
    final resp = await dio.put('notifications/read-all');
    return resp.statusCode == 200 || resp.statusCode == 204;
  }

  Future<bool> updateFcmToken(String fcmToken) async {
    final resp = await dio.put(
      'notifications/fcm-token',
      data: fcmToken, // Có thể điều chỉnh thành {'token': fcmToken} tùy API
    );
    return resp.statusCode == 200 || resp.statusCode == 204;
  }
}