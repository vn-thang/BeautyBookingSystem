class StorePaymentModel {
  final int id;
  final int bookingId;
  final String customerName;
  final String paymentMethod;
  final String paymentType;
  final double amount;
  final String status;
  final String? transactionId;
  final DateTime? paidAt;
  final String bookingStatus;

  StorePaymentModel({
    required this.id,
    required this.bookingId,
    required this.customerName,
    required this.paymentMethod,
    required this.paymentType,
    required this.amount,
    required this.status,
    this.transactionId,
    this.paidAt,
    required this.bookingStatus,
  });

  factory StorePaymentModel.fromJson(Map<String, dynamic> json) {
    return StorePaymentModel(
      id: json['id'] ?? 0,
      bookingId: json['bookingId'] ?? 0,
      customerName: json['customerName'] ?? 'Khách vãng lai',
      paymentMethod: json['paymentMethod'] ?? 'Cash',
      paymentType: json['paymentType'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? 'Pending',
      transactionId: json['transactionId'],
      paidAt: json['paidAt'] != null ? DateTime.tryParse(json['paidAt']) : null,
      bookingStatus: json['bookingStatus']?.toString() ?? '',
    );
  }
}