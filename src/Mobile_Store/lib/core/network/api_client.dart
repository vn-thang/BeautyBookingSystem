import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constant/api_constants.dart'; 
import '../constant/global_keys.dart';  
import '../../shared/token_storage.dart';

class ApiClient {
  static bool _isRefreshing = false;
  static Completer<bool>? _refreshCompleter;

  static Future<dynamic> get(String endpoint) async {
  final response = await _request('GET', endpoint);
  return _processResponse(response); 
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
  
static Future<List<int>> downloadFile(String endpoint) async {
    final response = await _request('GET', endpoint);

    if (response.statusCode == 200) {
      return response.bodyBytes; 
    } else {
      try {
        final json = jsonDecode(response.body);
        throw Exception(json['message'] ?? json.toString());
      } catch (_) {
        throw Exception('Đã xảy ra lỗi khi tải file (${response.statusCode})');
      }
    }
  }

  static Future<http.Response> _request(String method, String endpoint, {Map<String, dynamic>? body}) async {
    if (_isRefreshing) {
      await _refreshCompleter?.future;
    }

    var response = await _makeHttpCall(method, endpoint, body);

    if (response.statusCode == 401) {
      
      if (!_isRefreshing) {
        _isRefreshing = true;
        _refreshCompleter = Completer<bool>();

        bool isRefreshSuccess = await refreshToken();

        _isRefreshing = false; 
        _refreshCompleter?.complete(isRefreshSuccess); 

        if (isRefreshSuccess) {
          var retryResponse = await _makeHttpCall(method, endpoint, body);
          if (retryResponse.statusCode == 401) {
            await _handleSessionExpired();
          }
          return retryResponse;
        } else {
          await _handleSessionExpired();
          return response;
        }
      } 
      else {
        bool isRefreshSuccess = await _refreshCompleter!.future;
        if (isRefreshSuccess) {
          var retryResponse = await _makeHttpCall(method, endpoint, body);
          if (retryResponse.statusCode == 401) {
            await _handleSessionExpired();
          }
          return retryResponse;
        } else {
          return response; 
        }
      }
    }
    return response;
  }

  static Future<http.Response> _makeHttpCall(String method, String endpoint, Map<String, dynamic>? body) async {
    final token = await TokenStorage.getAccessToken();
    debugPrint("🔑 Token đang gửi đi: $token");
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
      throw Exception("Lỗi kết nối mạng: $e");
    }
  }

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
        final newAccess = data['accessToken']; 
        final newRefresh = data['refreshToken'];
        
        await TokenStorage.saveTokens(newAccess, newRefresh);
        
        debugPrint("✅ Làm mới Token thành công!");
        return true;
      }
      debugPrint("❌ C# Backend từ chối Refresh Token. Mã lỗi: ${response.statusCode}, Nội dung: ${response.body}");
      return false; 
    } catch (e) {
     debugPrint ("❌ Lỗi mạng khi Refresh Token: $e");
     return false;
    }
  }

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

    navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
  }

 static dynamic _processResponse(http.Response response) {
    dynamic json;
    try {
      json = response.body.isNotEmpty ? jsonDecode(response.body) : {};
    } catch (e) {
      debugPrint("⚠️ Lỗi Parse JSON: $e");
      if (response.body.toLowerCase() == 'true') return true;
      if (response.body.toLowerCase() == 'false') return false;
      json = {'message': response.body}; 
    }

    switch (response.statusCode) {
      case 200: 
      case 201: 
      case 204: 
        return json; 
        
      case 400: 
        debugPrint("❌ LỖI 400 RAW: ${response.body}");
        if (json is Map) {
          if (json.containsKey('errors') && json['errors'] is Map) {
            final errors = json['errors'] as Map;
            if (errors.isNotEmpty) {
              final firstError = errors.values.first[0];
              throw Exception(firstError.toString());
            }
          }
          throw Exception(json['message']?.toString() ?? 'Dữ liệu không hợp lệ (400)');
        }
        throw Exception('Dữ liệu không hợp lệ (400)');
      case 401: 
        throw Exception('Phiên đăng nhập đã hết hạn (401)'); 
      case 403: 
        throw Exception('Không có quyền thực hiện (403)');
      case 404: 
        if (json is Map && json.containsKey('message')) {
           throw Exception(json['message'].toString());
        }
        throw Exception('Không tìm thấy dữ liệu (404)');
      case 500: 
        throw Exception('Lỗi máy chủ. Vui lòng thử lại sau (500)');
      default: 
        if (json is Map && json.containsKey('message')) {
           throw Exception(json['message'].toString());
        }
        throw Exception('Đã có lỗi xảy ra (${response.statusCode})');
    }
  }
}