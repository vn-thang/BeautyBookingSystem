class BookingBillModel {
  final String storeName;
  final String storeAddress;
  final String storePhone;
  final int bookingId;
  final DateTime createdAt;
  final String customerName;
  final String customerPhone;
  final List<BillServiceItemModel> services;
  final double subTotal;
  final double discountAmount;
  final double finalTotal;
  final double depositAmount;
  final double amountToPay;

  BookingBillModel({
    required this.storeName,
    required this.storeAddress,
    required this.storePhone,
    required this.bookingId,
    required this.createdAt,
    required this.customerName,
    required this.customerPhone,
    required this.services,
    required this.subTotal,
    required this.discountAmount,
    required this.finalTotal,
    required this.depositAmount,
    required this.amountToPay,
  });

  factory BookingBillModel.fromJson(Map<String, dynamic> json) {
    return BookingBillModel(
      storeName: json['storeName'] ?? '',
      storeAddress: json['storeAddress'] ?? '',
      storePhone: json['storePhone'] ?? '',
      bookingId: json['bookingId'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      customerName: json['customerName'] ?? '',
      customerPhone: json['customerPhone'] ?? '',
      services: (json['services'] as List?)
              ?.map((item) => BillServiceItemModel.fromJson(item))
              .toList() ??
          [],
      subTotal: (json['subTotal'] ?? 0).toDouble(),
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      finalTotal: (json['finalTotal'] ?? 0).toDouble(),
      depositAmount: (json['depositAmount'] ?? 0).toDouble(),
      amountToPay: (json['amountToPay'] ?? 0).toDouble(),
    );
  }
}

class BillServiceItemModel {
  final String serviceName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  BillServiceItemModel({
    required this.serviceName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory BillServiceItemModel.fromJson(Map<String, dynamic> json) {
    return BillServiceItemModel(
      serviceName: json['serviceName'] ?? '',
      quantity: json['quantity'] ?? 1,
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
    );
  }
}