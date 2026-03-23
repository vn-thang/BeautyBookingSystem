import 'booking_detail_request.dart';

class BookingRequest {
  final int storeId;
  final int? voucherId;
  final String? customerNote;
  final int paymentMethod;
  final double depositAmount;
  final List<BookingDetailRequest> services;

  BookingRequest({
    required this.storeId,
    this.voucherId,
    this.customerNote,
    required this.paymentMethod,
    required this.depositAmount,
    required this.services,
  });
}
