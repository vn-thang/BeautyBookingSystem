import 'package:intl/intl.dart';

class Voucher {
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

  Voucher({
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

  String get discountText {
    if (discountType == 0) {
      final perc =
          discountValue % 1 == 0 ? discountValue.toInt() : discountValue;
      return '${perc}%';
    } else {
      final f =
          NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0);
      return '${f.format(discountValue)}₫';
    }
  }
}
