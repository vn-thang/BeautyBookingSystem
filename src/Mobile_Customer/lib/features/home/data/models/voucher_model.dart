import '../../domain/entities/voucher.dart';

class VoucherModel {
  final int id;
  final int storeId;
  final int? serviceId;

  final int discountType;
  final double discountValue;
  final double minOrderValue;
  final double maxDiscount;

  final String code;
  final String? imageUrl;

  final DateTime? startDate;
  final DateTime? endDate;

  final String? serviceName;
  final double originalPrice;
  final double discountedPrice;

  VoucherModel({
    required this.id,
    required this.storeId,
    this.serviceId,
    required this.discountType,
    required this.discountValue,
    required this.minOrderValue,
    required this.maxDiscount,
    required this.code,
    this.imageUrl,
    this.startDate,
    this.endDate,
    this.serviceName,
    this.originalPrice = 0,
    this.discountedPrice = 0,
  });

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  static DateTime? _toDate(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString());
  }

  static String? _toStringOrNull(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  factory VoucherModel.fromJson(Map<String, dynamic> json) {
    return VoucherModel(
      id: _toInt(json['id']),
      storeId: _toInt(json['storeId']),
      serviceId: json['serviceId'] != null ? _toInt(json['serviceId']) : null,
      discountType: _toInt(json['discountType']),
      discountValue: _toDouble(json['discountValue']),
      minOrderValue: _toDouble(json['minOrderValue']),
      maxDiscount: _toDouble(json['maxDiscount']),
      code: (json['code'] ?? '').toString(),
      imageUrl: _toStringOrNull(json['imageUrl'] ?? json['ImageUrl']),
      startDate: _toDate(json['startDate']),
      endDate: _toDate(json['endDate']),
      serviceName: _toStringOrNull(json['serviceName']),
      originalPrice: _toDouble(json['originalPrice']),
      discountedPrice: _toDouble(json['discountedPrice']),
    );
  }

  Voucher toEntity() {
    return Voucher(
      id: id,
      storeId: storeId,
      serviceId: serviceId,
      discountType: discountType,
      discountValue: discountValue,
      minOrderValue: minOrderValue,
      maxDiscount: maxDiscount,
      code: code,
      imageUrl: imageUrl,
      startDate: startDate,
      endDate: endDate,
      serviceName: serviceName,
      originalPrice: originalPrice,
      discountedPrice: discountedPrice,
    );
  }
}
