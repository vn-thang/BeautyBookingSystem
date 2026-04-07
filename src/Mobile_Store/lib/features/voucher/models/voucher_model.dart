class VoucherModel {
  final int id;
  final String code;
  final int? serviceId;
  final String? serviceName;
  final int discountType; // 0: Tiền mặt, 1: Phần trăm (%)
  final double discountValue;
  final double minOrderValue;
  final double maxDiscount;
  final DateTime startDate;
  final DateTime endDate;
  final int usageLimit;
  final int usedCount;
  final String status;

  VoucherModel({
    required this.id,
    required this.code,
    this.serviceId,
    this.serviceName,
    required this.discountType,
    required this.discountValue,
    required this.minOrderValue,
    required this.maxDiscount,
    required this.startDate,
    required this.endDate,
    required this.usageLimit,
    required this.usedCount,
    required this.status,
  });

  factory VoucherModel.fromJson(Map<String, dynamic> json) {
    return VoucherModel(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      serviceId: json['serviceId'],
      serviceName: json['serviceName'],
      discountType: json['discountType'] ?? 0,
      discountValue: (json['discountValue'] ?? 0).toDouble(),
      minOrderValue: (json['minOrderValue'] ?? 0).toDouble(),
      maxDiscount: (json['maxDiscount'] ?? 0).toDouble(),
      startDate: DateTime.parse(json['startDate']).toLocal(),
      endDate: DateTime.parse(json['endDate']).toLocal(),
      usageLimit: json['usageLimit'] ?? 0,
      usedCount: json['usedCount'] ?? 0,
      status: json['status'] ?? '',
    );
  }
}