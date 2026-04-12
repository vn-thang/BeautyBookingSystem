class BookingPolicy {
  final int bookingMinHours;
  final int cancelBeforeHours;
  final int gracePeriodMinutes;
  final int maxCancelPerDay;
  final int noShowLimit;
  final bool blockUserIfNoShow;
  final int rescheduleBeforeHours;
  final bool isBookingBlocked;
  final int currentNoShowCount;
  final int currentCancelCountToday;
  final String? blockReason;

  BookingPolicy({
    required this.bookingMinHours,
    required this.cancelBeforeHours,
    required this.gracePeriodMinutes,
    required this.maxCancelPerDay,
    required this.noShowLimit,
    required this.blockUserIfNoShow,
    required this.rescheduleBeforeHours,
    required this.isBookingBlocked,
    required this.currentNoShowCount,
    required this.currentCancelCountToday,
    required this.blockReason,
  });

  factory BookingPolicy.fromJson(Map<String, dynamic> json) {
    return BookingPolicy(
      bookingMinHours: json['bookingMinHours'] ?? 2,
      cancelBeforeHours: json['cancelBeforeHours'] ?? 3,
      gracePeriodMinutes: json['gracePeriodMinutes'] ?? 30,
      maxCancelPerDay: json['maxCancelPerDay'] ?? 0,
      noShowLimit: json['noShowLimit'] ?? 5,
      blockUserIfNoShow: json['blockUserIfNoShow'] ?? false,
      rescheduleBeforeHours: json['rescheduleBeforeHours'] ?? 2,
      isBookingBlocked: json['isBookingBlocked'] ?? false,
      currentNoShowCount: json['currentNoShowCount'] ?? 0,
      currentCancelCountToday: json['currentCancelCountToday'] ?? 0,
      blockReason: json['blockReason'],
    );
  }
}
