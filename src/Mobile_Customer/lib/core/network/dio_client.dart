import 'package:dio/dio.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/router/app_router.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../../injection/service_locator.dart' as di;

class ApiConfig {
  static const bool _isEmulator = false;
  static String get baseUrl {
    if (kIsWeb) {
      return "http://localhost:5294/api/";
    }

    if (Platform.isAndroid) {
      if (_isEmulator) {
        return "http://10.0.2.2:5294/api/";
      } else {
        return "http://192.168.1.10:5294/api/";
      }
    }

    return "http://localhost:5294/api/";
  }

  // static String get baseUrl {
  //   return "https://doreatha-absolvable-astrid.ngrok-free.dev/api/";
  // }
}

class DioClient {
  final Dio dio;
  bool _isRefreshing = false;

  DioClient()
      : dio = Dio(
          BaseOptions(
            baseUrl: ApiConfig.baseUrl,
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
            headers: {
              "Content-Type": "application/json",
            },
          ),
        ) {
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString("token");

          if (token != null &&
              token.isNotEmpty &&
              options.extra['skipAuth'] != true) {
            options.headers["Authorization"] = "Bearer $token";
          }

          handler.next(options);
        },
        onError: (error, handler) async {
          final statusCode = error.response?.statusCode;
          final options = error.requestOptions;

          final isRefreshCall = options.path.contains("auth/refresh-token");
          final alreadyRetried = options.extra["retried"] == true;
          final allowGuest = options.extra["allowGuest"] == true;

          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString("token");

          if (statusCode == 401 && !isRefreshCall && !alreadyRetried) {
            // Chưa login hoặc endpoint cho phép guest => không logout
            if (token == null || token.isEmpty || allowGuest) {
              return handler.next(error);
            }

            final refreshed = await _refreshToken();

            if (refreshed) {
              try {
                options.extra["retried"] = true;
                final response = await dio.fetch(options);
                return handler.resolve(response);
              } catch (_) {
                // retry fail thì logout bên dưới
              }
            }

            await _forceLogout();
            return;
          }

          handler.next(error);
        },
      ),
    );
  }

  Future<bool> _refreshToken() async {
    if (_isRefreshing) {
      while (_isRefreshing) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return true;
    }

    _isRefreshing = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString("token");
      final refreshToken = prefs.getString("refreshToken");

      if (accessToken == null ||
          accessToken.isEmpty ||
          refreshToken == null ||
          refreshToken.isEmpty) {
        return false;
      }

      final refreshDio = Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          headers: {
            "Content-Type": "application/json",
          },
        ),
      );

      final response = await refreshDio.post(
        "auth/refresh-token",
        data: {
          "accessToken": accessToken,
          "refreshToken": refreshToken,
        },
      );

      final data = response.data["data"] ?? response.data;

      final newAccessToken = data["accessToken"];
      final newRefreshToken = data["refreshToken"];

      if (newAccessToken == null || newRefreshToken == null) {
        return false;
      }

      await prefs.setString("token", newAccessToken);
      await prefs.setString("refreshToken", newRefreshToken);

      return true;
    } catch (_) {
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> _forceLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    await prefs.remove("refreshToken");
    await prefs.remove("user");
    await prefs.setString("sessionExpired", "1");

    di.sl<AuthBloc>().add(LogoutEvent());

    Future.microtask(() {
      AppRouter.router.go("/login");
    });
  }
}

/*
	9704198526191432198
  	NGUYEN VAN A
    07/15
    */