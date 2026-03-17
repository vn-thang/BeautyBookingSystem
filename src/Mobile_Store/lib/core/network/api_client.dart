import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constant/api_constants.dart'; 
import '../constant/global_keys.dart';  
import '../../shared/token_storage.dart';

class ApiClient {
  // 1. CÁC BIẾN QUẢN LÝ HÀNG ĐỢI (QUEUE/LOCK)
  static bool _isRefreshing = false;
  static Completer<bool>? _refreshCompleter;

  static Future<dynamic> get(String endpoint) async {
  final response = await _request('GET', endpoint);
  return _processResponse(response); // Nhả luôn JSON ra
}

static Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
  final response = await _request('POST', endpoint, body: body);
  return _processResponse(response);
}

static Future<dynamic> put(String endpoint, {Map<String, dynamic>? body}) async {
  final response = await _request('PUT', endpoint, body: body);
  return _processResponse(response);
}

static Future<dynamic> delete(String endpoint) async {
  final response = await _request('DELETE', endpoint);
  return _processResponse(response);
}
  
  static Future<http.Response> _request(String method, String endpoint, {Map<String, dynamic>? body}) async {
    // 3.1. Nếu có người đang đi xin Token, tất cả request mới phải đứng chờ ở đây
    if (_isRefreshing) {
      await _refreshCompleter?.future;
    }

    // 3.2. Thực hiện gọi API
    var response = await _makeHttpCall(method, endpoint, body);

    // 3.3. Bắt lỗi 401 (Hết hạn Access Token)
    if (response.statusCode == 401) {
      
      if (!_isRefreshing) {
        _isRefreshing = true;
        _refreshCompleter = Completer<bool>();

        bool isRefreshSuccess = await refreshToken();

        _isRefreshing = false; 
        _refreshCompleter?.complete(isRefreshSuccess); 

        if (isRefreshSuccess) {
          // Xin thành công -> Gọi lại API ban đầu với Token mới
          return await _makeHttpCall(method, endpoint, body);
        } else {
          // Xin thất bại (Refresh Token cũng hết hạn) -> Xử lý văng App
          await _handleSessionExpired();
          return response;
        }
      } 
      else {
        bool isRefreshSuccess = await _refreshCompleter!.future;
        if (isRefreshSuccess) {
          return await _makeHttpCall(method, endpoint, body); // Chạy lại với token mới
        } else {
          return response; // Thất bại thì trả về lỗi nguyên bản
        }
      }
    }

    // Trả về kết quả bình thường nếu không phải lỗi 401
    return response;
  }

  // Hàm tạo Request có nhúng sẵn Token mới nhất
  static Future<http.Response> _makeHttpCall(String method, String endpoint, Map<String, dynamic>? body) async {
    final token = await TokenStorage.getAccessToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    final jsonBody = body != null ? jsonEncode(body) : null;

    try {
      switch (method) {
        case 'POST': return await http.post(uri, headers: headers, body: jsonBody);
        case 'PUT': return await http.put(uri, headers: headers, body: jsonBody);
        case 'DELETE': return await http.delete(uri, headers: headers);
        default: return await http.get(uri, headers: headers);
      }
    } catch (e) {
      // Bắt lỗi mất mạng hoặc server sập
      throw Exception("Lỗi kết nối mạng: $e");
    }
  }

  // Hàm âm thầm gọi lên C# xin Token mới
  static Future<bool> refreshToken() async {
    try {
      final accessToken = await TokenStorage.getAccessToken();
      final refreshToken = await TokenStorage.getRefreshToken();
      
      if (accessToken == null || refreshToken == null) return false;

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/Auth/refresh-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'accessToken': accessToken,
          'refreshToken': refreshToken
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final data = json['data'] ?? json;
        final newAccess = data['accessToken']; // Nhớ check key 'data' có đúng với JSON C# trả về không nhé
        final newRefresh = data['refreshToken'];
        
        await TokenStorage.saveTokens(newAccess, newRefresh);
       debugPrint("❌ C# Backend từ chối Refresh Token. Mã lỗi: ${response.statusCode}, Nội dung: ${response.body}");
        return true;
      }
      return false; 
    } catch (e) {
     debugPrint ("❌ Lỗi mạng khi Refresh Token: $e");
      return false;
    }
  }

  // Hàm xử lý khi phiên đăng nhập tèo hoàn toàn
  static Future<void> _handleSessionExpired() async {
    await TokenStorage.clearTokens();
    
    final context = navigatorKey.currentContext;
   if (context != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại!'),
          backgroundColor: Colors.red,
        ),
      );
    }

    // 3. Đá văng ra màn hình Login (Dùng currentState thẳng luôn, không bị lỗi)
    navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
  }

  static dynamic _processResponse(http.Response response) {
  final json = response.body.isNotEmpty ? jsonDecode(response.body) : {};
  switch (response.statusCode) {
    case 200: case 201: case 204: return json;
    case 400: throw Exception(json['message'] ?? 'Dữ liệu không hợp lệ');
    case 403: throw Exception('Không có quyền thực hiện');
    case 404: throw Exception(json['message'] ?? 'Không tìm thấy dữ liệu');
    case 500: throw Exception('Lỗi máy chủ. Vui lòng thử lại sau');
    default: throw Exception(json['message'] ?? 'Đã có lỗi xảy ra (${response.statusCode})');
  }
}
}