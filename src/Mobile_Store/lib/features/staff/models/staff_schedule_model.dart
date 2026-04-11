import 'package:flutter/material.dart';

class StaffScheduleModel {
  int dayOfWeek; // 0 = Sunday, 1 = Monday, ...
  TimeOfDay startTime;
  TimeOfDay endTime;
  bool isWorking;

  StaffScheduleModel({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.isWorking,
  });

  factory StaffScheduleModel.fromJson(Map<String, dynamic> json) {
    return StaffScheduleModel(
      dayOfWeek: json['dayOfWeek'] ?? 1,
      startTime: _parseTime(json['startTime'] ?? '08:00:00'),
      endTime: _parseTime(json['endTime'] ?? '17:00:00'),
      isWorking: json['isWorking'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "dayOfWeek": dayOfWeek,
      "startTime": _formatTime(startTime),
      "endTime": _formatTime(endTime),
      "isWorking": isWorking,
    };
  }

  static TimeOfDay _parseTime(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  static String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
  }
  
  String get dayName {
    switch (dayOfWeek) {
      case 0: return 'Chủ Nhật';
      case 1: return 'Thứ Hai';
      case 2: return 'Thứ Ba';
      case 3: return 'Thứ Tư';
      case 4: return 'Thứ Năm';
      case 5: return 'Thứ Sáu';
      case 6: return 'Thứ Bảy';
      default: return '';
    }
  }
}