import '../../domain/entities/booking_detail_request.dart';

class BookingDetailRequestModel extends BookingDetailRequest {
  BookingDetailRequestModel({
    required super.serviceId,
    super.staffId,
    required super.appointmentDate,
    required super.startTime,
  });

  Map<String, dynamic> toJson() {
    return {
      "serviceId": serviceId,
      "staffId": staffId,
      "appointmentDate": appointmentDate.toIso8601String(),
      "startTime": startTime
    };
  }
}