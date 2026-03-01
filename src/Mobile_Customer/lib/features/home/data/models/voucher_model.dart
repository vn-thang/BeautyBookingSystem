import '../../domain/entities/voucher.dart';

class VoucherModel {
  final int id;
  final String code;
  final double discountValue;

  VoucherModel({
    required this.id,
    required this.code,
    required this.discountValue,
  });

  factory VoucherModel.fromJson(Map<String, dynamic> json) {
    return VoucherModel(
      id: json['id'] as int,
      code: json['code'] as String,
      discountValue: (json['discountValue'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Voucher toEntity() {
    return Voucher(
      id: id,
      code: code,
      discountValue: discountValue,
    );
  }
}