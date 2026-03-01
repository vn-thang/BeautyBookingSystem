import 'package:dio/dio.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSource(this.dio);

  Future<(String token, UserModel user)> login({
    required String phone,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        "/auth/login",
        data: {
          "phone": phone,
          "password": password,
        },
      );

      print("STATUS CODE: ${response.statusCode}");
      print("RESPONSE DATA: ${response.data}");

      if (response.statusCode == 200) {
        final String token = response.data["token"];
        final user = UserModel.fromJson(response.data["user"]);
        return (token, user);
      } else {
        throw Exception("Login failed: ${response.data}");
      }
    } on DioException catch (e) {
      print("DIO ERROR STATUS: ${e.response?.statusCode}");
      print("DIO ERROR DATA: ${e.response?.data}");
      print("DIO ERROR MESSAGE: ${e.message}");

      throw Exception(
        e.response?.data.toString() ?? "Network error occurred",
      );
    } catch (e) {
      print("UNKNOWN ERROR: $e");
      rethrow;
    }
  }
}