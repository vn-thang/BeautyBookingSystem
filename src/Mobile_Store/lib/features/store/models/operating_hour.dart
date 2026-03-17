
class OperatingHour {
  int dayOfWeek; // 0: CN, 1: T2, ..., 6: T7
  String openTime;
  String closeTime;
  bool isActive; 

  OperatingHour({
    required this.dayOfWeek,
    required this.openTime,
    required this.closeTime,
    this.isActive = true, 
  });
  factory OperatingHour.fromJson(Map<String, dynamic> json) {
    String formatTime(dynamic timeString) {
      if (timeString == null) return '08:00';
      String time = timeString.toString();
      return time.length > 5 ? time.substring(0, 5) : time; 
    }

    return OperatingHour(
      dayOfWeek: json['dayOfWeek'] ?? 0,
      openTime: formatTime(json['openTime']),
      closeTime: formatTime(json['closeTime']),
      isActive: true, 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dayOfWeek': dayOfWeek,
      'openTime': openTime,
      'closeTime': closeTime,
    };
  }
}