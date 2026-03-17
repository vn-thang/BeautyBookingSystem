class StoreBookingListModel {
  final int id;
  final String customerName;
  final String customerPhone;
  final double finalPrice;
  final String status;
  final DateTime createdAt;

  StoreBookingListModel({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.finalPrice,
    required this.status,
    required this.createdAt,
  });

  factory StoreBookingListModel.fromJson(Map<String, dynamic> json) {
    return StoreBookingListModel(
      id: json['id'] ?? 0,
      customerName: json['customerName'] ?? '',
      customerPhone: json['customerPhone'] ?? '',
      finalPrice: (json['finalPrice'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class StoreBookingDetailModel extends StoreBookingListModel {
  final String? customerNote;
  final double totalPrice;
  final double discountAmount;
  final String? cancelReason;
  final String? cancelledBy;
  final int? paymentId;
  final List<BookingServiceModel> services;

  StoreBookingDetailModel({
    required super.id,
    required super.customerName,
    required super.customerPhone,
    required super.finalPrice,
    required super.status,
    required super.createdAt,
    this.customerNote,
    required this.totalPrice,
    required this.discountAmount,
    this.cancelReason,
    this.cancelledBy,
    required this.services,
    this.paymentId
  });

  factory StoreBookingDetailModel.fromJson(Map<String, dynamic> json) {
    var servicesList = json['services'] as List? ?? [];
    return StoreBookingDetailModel(
      id: json['id'] ?? 0,
      customerName: json['customerName'] ?? '',
      customerPhone: json['customerPhone'] ?? '',
      finalPrice: (json['finalPrice'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      customerNote: json['customerNote'],
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      cancelReason: json['cancelReason'],
      cancelledBy: json['cancelledBy'],
      paymentId: json['paymentId'],
      services: servicesList.map((e) => BookingServiceModel.fromJson(e)).toList(),
    );
  }
}

class BookingServiceModel {
  final int bookingDetailId;
  final String serviceName;
  final DateTime appointmentDate;
  final String startTime; 
  final String endTime;
  final double price;
  final int? staffId;
  final String? staffName;
  final String detailStatus;

  BookingServiceModel({
    required this.bookingDetailId,
    required this.serviceName,
    required this.appointmentDate,
    required this.startTime,
    required this.endTime,
    required this.price,
    this.staffId,
    this.staffName,
    required this.detailStatus,
  });

  factory BookingServiceModel.fromJson(Map<String, dynamic> json) {
    return BookingServiceModel(
      bookingDetailId: json['bookingDetailId'] ?? 0,
      serviceName: json['serviceName'] ?? '',
      appointmentDate: DateTime.parse(json['appointmentDate']),
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      staffId: json['staffId'],
      staffName: json['staffName'],
      detailStatus: json['detailStatus'] ?? '',
    );
  }
}

class AvailableStaffModel {
  final int id;
  final String fullName;
  final String? avatarUrl;
  final String position;
  

  AvailableStaffModel({
    required this.id,
    required this.fullName,
    this.avatarUrl,
    required this.position,
    
  });

  factory AvailableStaffModel.fromJson(Map<String, dynamic> json) {
    return AvailableStaffModel(
      id: json['id'] ?? 0,
      fullName: json['fullName'] ?? '',
      avatarUrl: json['avatarUrl'],
      position: json['position'] ?? '',
    );
  }
}