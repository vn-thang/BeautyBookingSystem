abstract class BookingEvent {}

class FetchAvailableStaffEvent extends BookingEvent {
  final int storeId;
  final int serviceId;
  final DateTime appointmentDate;
  final String startTime;

  FetchAvailableStaffEvent({
    required this.storeId,
    required this.serviceId,
    required this.appointmentDate,
    required this.startTime,
  });
}