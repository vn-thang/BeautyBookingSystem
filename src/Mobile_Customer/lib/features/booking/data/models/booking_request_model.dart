import '../../domain/entities/booking_request.dart';
import 'booking_detail_request_model.dart';

class BookingRequestModel extends BookingRequest {
  BookingRequestModel({
    required super.storeId,
    super.voucherId,
    super.customerNote,
    required super.paymentMethod,
    required super.depositAmount,
    required super.services,
  });

  Map<String, dynamic> toJson() {
    return {
      "storeId": storeId,
      "voucherId": voucherId,
      "customerNote": customerNote,
      "paymentMethod": paymentMethod,
      "depositAmount": depositAmount,
      "services": services
          .map((e) => (e as BookingDetailRequestModel).toJson())
          .toList(),
    };
  }

  factory BookingRequestModel.fromDomain(BookingRequest r) {
    return BookingRequestModel(
      storeId: r.storeId,
      voucherId: r.voucherId,
      customerNote: r.customerNote,
      paymentMethod: r.paymentMethod,
      depositAmount: r.depositAmount,
      services: r.services
          .map((s) => BookingDetailRequestModel(
                serviceId: s.serviceId,
                staffId: s.staffId,
                appointmentDate: s.appointmentDate,
                startTime: s.startTime,
              ))
          .toList(),
    );
  }
}
