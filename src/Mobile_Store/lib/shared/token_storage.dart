import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {

  // LƯU CẢ 2 TOKEN CÙNG LÚC
  static Future<void> saveTokens(
      String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("accessToken", accessToken);
    await prefs.setString("refreshToken", refreshToken);
  }

  // LẤY ACCESS TOKEN
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("accessToken");
  }

  // 👉 BỔ SUNG: LẤY REFRESH TOKEN (Rất quan trọng để gia hạn)
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("refreshToken");
  }

  // XÓA SẠCH TOKEN KHI ĐĂNG XUẤT HOẶC HẾT HẠN
  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("accessToken");
    await prefs.remove("refreshToken");
    // Lưu ý: Thường mình chỉ remove token chứ không dùng .clear() 
    // vì .clear() sẽ xóa sạch cả storeId, theme, ngôn ngữ... của app.
  }

  // THÊM HÀM LƯU STORE ID
  static Future<void> saveStoreId(int storeId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("storeId", storeId);
  }

  // THÊM HÀM LẤY STORE ID
  static Future<int?> getStoreId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("storeId");
  }
}