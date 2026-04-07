import '../entities/booking_request.dart';
import '../repositories/booking_repository.dart';

class CreateBooking {
  final BookingRepository repository;

  CreateBooking(this.repository);

  Future<void> call(BookingRequest request) async {
    await repository.createBooking(request);
  }
}