class CustomerServiceHistoryModel {
  final int bookingId;
  final DateTime? appointmentDate;
  final String startTime; 
  final String serviceName;
  final String staffName;
  final double price;

  CustomerServiceHistoryModel({
    required this.bookingId,
    this.appointmentDate,
    required this.startTime,
    required this.serviceName,
    required this.staffName,
    required this.price,
  });

  factory CustomerServiceHistoryModel.fromJson(Map<String, dynamic> json) {
    return CustomerServiceHistoryModel(
      bookingId: json['bookingId'] ?? 0,
      appointmentDate: json['appointmentDate'] != null 
          ? DateTime.tryParse(json['appointmentDate']) 
          : null,
      startTime: json['startTime'] ?? '',
      serviceName: json['serviceName'] ?? '',
      staffName: json['staffName'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
    );
  }
}

class CustomerProfileModel {
  final int customerId;
  final String fullName;
  final String phone;
  final String? avatarUrl;
  final int totalVisits;
  final double totalSpent;
  final int totalCancelled; 
  final List<CustomerServiceHistoryModel> serviceHistories;

  CustomerProfileModel({
    required this.customerId,
    required this.fullName,
    required this.phone,
    this.avatarUrl,
    required this.totalVisits,
    required this.totalSpent,
    required this.totalCancelled,
    required this.serviceHistories,
  });

  factory CustomerProfileModel.fromJson(Map<String, dynamic> json) {
    return CustomerProfileModel(
      customerId: json['customerId'] ?? 0,
      fullName: json['fullName'] ?? '',
      phone: json['phone'] ?? '',
      avatarUrl: json['avatarUrl'],
      totalVisits: json['totalVisits'] ?? 0,
      totalSpent: (json['totalSpent'] ?? 0).toDouble(),
      totalCancelled: json['totalCancelled'] ?? 0,
      serviceHistories: (json['serviceHistories'] as List?)
              ?.map((e) => CustomerServiceHistoryModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}