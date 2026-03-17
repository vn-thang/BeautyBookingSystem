// file: lib/models/operating_hour.dart

class OperatingHour {
  int dayOfWeek; // 0: CN, 1: T2, ..., 6: T7
  String openTime;
  String closeTime;
  
  // Biến này chỉ dùng ở Frontend (UI) để bật/tắt ngày, không gửi lên Backend
  bool isActive; 

  OperatingHour({
    required this.dayOfWeek,
    required this.openTime,
    required this.closeTime,
    this.isActive = true, // Mặc định là true nếu có dữ liệu
  });
// Chuyển từ JSON (API) sang Object
  factory OperatingHour.fromJson(Map<String, dynamic> json) {
    // Ép kiểu an toàn và cắt lấy 5 ký tự (HH:mm) để tránh dính giây (HH:mm:ss) từ C#
    String formatTime(dynamic timeString) {
      if (timeString == null) return '08:00';
      String time = timeString.toString();
      return time.length > 5 ? time.substring(0, 5) : time; // VD: '08:00:00' -> '08:00'
    }

    return OperatingHour(
      dayOfWeek: json['dayOfWeek'] ?? 0,
      openTime: formatTime(json['openTime']),
      closeTime: formatTime(json['closeTime']),
      isActive: true, // Nếu API trả về nghĩa là ngày này đang hoạt động
    );
  }

  // Chuyển từ Object sang JSON (để gửi lên API)
  // Chỉ lấy đúng 3 trường theo C# DTO
  Map<String, dynamic> toJson() {
    return {
      'dayOfWeek': dayOfWeek,
      'openTime': openTime,
      'closeTime': closeTime,
    };
  }
}