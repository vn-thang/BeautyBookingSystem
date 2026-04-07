class BookingDetailRequest {
  final int serviceId;
  final int? staffId;
  final DateTime appointmentDate;
  final String startTime;

  BookingDetailRequest({
    required this.serviceId,
    this.staffId,
    required this.appointmentDate,
    required this.startTime,
  });
}