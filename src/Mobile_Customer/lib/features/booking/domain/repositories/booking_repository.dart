import '../entities/booking_request.dart';
import '../entities/available_staff.dart';

abstract class BookingRepository {
  Future<void> createBooking(BookingRequest request);
  Future<List<AvailableStaff>> getAvailableStaff({
    required int storeId,
    required int serviceId,
    required DateTime appointmentDate,
    required String startTime,
  });
}