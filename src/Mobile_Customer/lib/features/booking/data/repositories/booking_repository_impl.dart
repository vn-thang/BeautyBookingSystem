import '../../domain/entities/booking_request.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_datasource.dart';
import '../models/booking_request_model.dart';
import '../../domain/entities/available_staff.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource remote;

  BookingRepositoryImpl(this.remote);

  @override
  Future<void> createBooking(BookingRequest request) async {
    final model = BookingRequestModel.fromDomain(request);
    await remote.createBooking(model);
  }
    @override
  Future<List<AvailableStaff>> getAvailableStaff({
    required int storeId,
    required int serviceId,
    required DateTime appointmentDate,
    required String startTime,
  }) {
    return remote.getAvailableStaff(
      storeId: storeId,
      serviceId: serviceId,
      appointmentDate: appointmentDate,
      startTime: startTime,
    );
  }
}