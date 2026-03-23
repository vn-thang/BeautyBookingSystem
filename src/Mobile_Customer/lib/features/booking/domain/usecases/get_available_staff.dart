import '../entities/available_staff.dart';
import '../repositories/booking_repository.dart';

class GetAvailableStaff {
  final BookingRepository repository;
  GetAvailableStaff(this.repository);

  Future<List<AvailableStaff>> call({
    required int storeId,
    required int serviceId,
    required DateTime appointmentDate,
    required String startTime,
  }) {
    return repository.getAvailableStaff(
      storeId: storeId,
      serviceId: serviceId,
      appointmentDate: appointmentDate,
      startTime: startTime,
    );
  }
}