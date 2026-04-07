class OperatingHourViewDto {
  final int dayOfWeek;
  final String openTime;
  final String closeTime;

  OperatingHourViewDto({
    required this.dayOfWeek,
    required this.openTime,
    required this.closeTime,
  });

  factory OperatingHourViewDto.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic x) {
      if (x is int) return x;
      if (x is double) return x.toInt();
      return int.tryParse(x.toString()) ?? 0;
    }

    return OperatingHourViewDto(
      dayOfWeek: parseInt(json['dayOfWeek']),
      openTime: json['openTime']?.toString() ?? '',
      closeTime: json['closeTime']?.toString() ?? '',
    );
  }
}
