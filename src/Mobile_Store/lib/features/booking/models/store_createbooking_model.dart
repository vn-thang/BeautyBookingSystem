class TimeSlotModel {
  final String time;
  final bool isAvailable;

  TimeSlotModel({required this.time, required this.isAvailable});

  factory TimeSlotModel.fromJson(Map<String, dynamic> json) {
    return TimeSlotModel(
      time: json['time'] ?? '',
      isAvailable: json['isAvailable'] ?? false,
    );
  }
}

class CreateStoreBookingRequest {
  final String customerName;
  final String? customerPhone;
  final DateTime appointmentDate;
  final String? note;
  final List<StoreBookingServiceRequest> services;

  CreateStoreBookingRequest({
    required this.customerName,
    this.customerPhone,
    required this.appointmentDate,
    this.note,
    required this.services,
  });

  Map<String, dynamic> toJson() {
    return {
      'customerName': customerName,
      'customerPhone': customerPhone,
      'appointmentDate': appointmentDate.toIso8601String(),
      'note': note,
      'services': services.map((s) => s.toJson()).toList(),
    };
  }
}

class StoreBookingServiceRequest {
  final int serviceId;
  final String startTime; 
  final int? staffId;

  StoreBookingServiceRequest({
    required this.serviceId,
    required this.startTime,
    this.staffId,
  });

  Map<String, dynamic> toJson() {
    return {
      'serviceId': serviceId,
      'startTime': startTime,
      'staffId': staffId,
    };
  }
}
class BookingResponseDto {
  final int id;
  final double totalPrice;
  final double discountAmount;
  final double depositAmount;
  final double finalPrice;
  final String status;
  final List<BookingDetailResponseDto> services;

  BookingResponseDto({
    required this.id,
    required this.totalPrice,
    required this.discountAmount,
    required this.depositAmount,
    required this.finalPrice,
    required this.status,
    required this.services,
  });

  factory BookingResponseDto.fromJson(Map<String, dynamic> json) {
    var servicesList = json['services'] as List? ?? [];
    
    return BookingResponseDto(
      id: json['id'] ?? 0,
      totalPrice: double.tryParse(json['totalPrice']?.toString() ?? '0') ?? 0.0,
      discountAmount: double.tryParse(json['discountAmount']?.toString() ?? '0') ?? 0.0,
      depositAmount: double.tryParse(json['depositAmount']?.toString() ?? '0') ?? 0.0,
      finalPrice: double.tryParse(json['finalPrice']?.toString() ?? '0') ?? 0.0,
      
      status: json['status']?.toString() ?? '', 
      
      services: servicesList.map((e) => BookingDetailResponseDto.fromJson(e)).toList(),
    );
  }
}

class BookingDetailResponseDto {
  final int serviceId;
  final String serviceName;
  final int? staffId;
  final DateTime appointmentDate;
  final String startTime;
  final String endTime;
  final double price;

  BookingDetailResponseDto({
    required this.serviceId,
    required this.serviceName,
    this.staffId,
    required this.appointmentDate,
    required this.startTime,
    required this.endTime,
    required this.price,
  });

  factory BookingDetailResponseDto.fromJson(Map<String, dynamic> json) {
    return BookingDetailResponseDto(
      serviceId: json['serviceId'] ?? 0,
      serviceName: json['serviceName'] ?? '',
      staffId: json['staffId'], 
      
      appointmentDate: DateTime.tryParse(json['appointmentDate']?.toString() ?? '') ?? DateTime.now(),
      
      startTime: json['startTime']?.toString() ?? '',
      endTime: json['endTime']?.toString() ?? '',
      
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
    );
  }
}