import 'package:intl/intl.dart';

class BookingItem {
  final int id;
  final DateTime? createdAt;
  final DateTime? appointmentDateTime;
  final double totalPrice;
  final double discountAmount;
  final double depositAmount;
  final double finalPrice;
  final double paidAmountFromApi;
  final double remainingAmountFromApi;
  final int status;
  final String? customerNote;
  final String? storeName;
  final String? storeAvatarUrl;
  final String? staffName;
  final String? staffAvatarUrl;
  final String? mainServiceName;
  final int extraServiceCount;
  final String? serviceSummary;
  final List<BookingServiceItem> services;
  final List<BookingPaymentItem> payments;

  BookingItem({
    required this.id,
    this.createdAt,
    this.appointmentDateTime,
    required this.totalPrice,
    required this.discountAmount,
    required this.depositAmount,
    required this.finalPrice,
    this.paidAmountFromApi = 0,
    this.remainingAmountFromApi = 0,
    required this.status,
    this.customerNote,
    this.storeName,
    this.storeAvatarUrl,
    this.staffName,
    this.staffAvatarUrl,
    this.mainServiceName,
    this.extraServiceCount = 0,
    this.serviceSummary,
    required this.services,
    required this.payments,
  });

  factory BookingItem.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      if (v is String) return DateTime.tryParse(v);
      if (v is DateTime) return v;
      return null;
    }

    int parseInt(dynamic v, [int fallback = 0]) {
      if (v is int) return v;
      if (v is String) return int.tryParse(v) ?? fallback;
      return fallback;
    }

    double parseDouble(dynamic v, [double fallback = 0]) {
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? fallback;
      return fallback;
    }

    final servicesJson = (json['services'] as List?) ??
        (json['items'] is List ? json['items'] as List : null) ??
        [];
    final services = servicesJson
        .whereType<Map>()
        .map((e) => BookingServiceItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    final paymentsJson = (json['payments'] as List?) ?? [];
    final payments = paymentsJson
        .whereType<Map>()
        .map((e) => BookingPaymentItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return BookingItem(
      id: parseInt(json['id']),
      createdAt: parseDate(json['createdAt']),
      appointmentDateTime: parseDate(json['appointmentDateTime']),
      totalPrice: parseDouble(json['totalPrice']),
      discountAmount: parseDouble(json['discountAmount']),
      depositAmount: parseDouble(json['depositAmount']),
      finalPrice: parseDouble(json['finalPrice']),
      paidAmountFromApi: parseDouble(json['paidAmount']),
      remainingAmountFromApi: parseDouble(json['remainingAmount']),
      status: parseInt(json['status']),
      customerNote: json['customerNote'] as String?,
      storeName: json['storeName'] as String?,
      storeAvatarUrl:
          json['storeAvatarUrl'] as String? ?? json['storeImageUrl'] as String?,
      staffName: json['staffName'] as String?,
      staffAvatarUrl: json['staffAvatarUrl'] as String?,
      mainServiceName: json['mainServiceName'] as String?,
      extraServiceCount: parseInt(json['extraServiceCount']),
      serviceSummary: json['serviceSummary'] as String?,
      services: services,
      payments: payments,
    );
  }

  double get depositPaidAmount {
    return payments
        .where((p) => p.status == 1 && p.paymentType == 0)
        .fold(0.0, (sum, p) => sum + p.amount);
  }

  double get paidAmount {
    return payments
        .where((p) => p.status == 1 && p.paymentType == 1)
        .fold(0.0, (sum, p) => sum + p.amount);
  }

  double get remainingAmount {
    if (remainingAmountFromApi > 0) return remainingAmountFromApi;
    final remaining = finalPrice - depositPaidAmount - paidAmount;
    return remaining < 0 ? 0 : remaining;
  }

  String get effectiveServiceSummary {
    if ((serviceSummary ?? '').trim().isNotEmpty) return serviceSummary!;
    if (services.isEmpty) return '-';
    if (services.length == 1) return services.first.serviceName;
    return '${services.first.serviceName} + ${services.length - 1} dịch vụ khác';
  }

  String get statusText {
    switch (status) {
      case 0:
        return 'Chờ xác nhận';
      case 1:
        return 'Đã xác nhận';
      case 2:
        return 'Hoàn thành';
      case 3:
        return 'Đã hủy';
      default:
        return 'Không xác định';
    }
  }

  String get createdAtText {
    if (createdAt == null) return '-';
    return DateFormat('dd/MM/yyyy').format(createdAt!);
  }

  String get appointmentText {
    final dt = appointmentDateTime ??
        (services.isNotEmpty ? services.first.appointmentDate : null);
    if (dt == null) return '-';
    return DateFormat('dd/MM/yyyy HH:mm').format(dt);
  }
}

class BookingServiceItem {
  final int id;
  final int serviceId;
  final String serviceName;
  final int? staffId;
  final String? staffName;
  final String? staffAvatarUrl;
  final DateTime appointmentDate;
  final String startTime;
  final String? endTime;
  final double price;
  final int? status;

  BookingServiceItem({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    this.staffId,
    this.staffName,
    this.staffAvatarUrl,
    required this.appointmentDate,
    required this.startTime,
    this.endTime,
    required this.price,
    this.status,
  });

  factory BookingServiceItem.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
      if (v is DateTime) return v;
      return DateTime.now();
    }

    String normalizeStartTime(String s) {
      if (s.contains(':')) {
        final parts = s.split(':');
        if (parts.length >= 2) {
          return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
        }
      }
      return s;
    }

    int parseInt(dynamic v, [int fallback = 0]) {
      if (v is int) return v;
      if (v is String) return int.tryParse(v) ?? fallback;
      return fallback;
    }

    final startRaw =
        (json['startTime'] as String?) ?? (json['start'] as String?) ?? '';
    final start = normalizeStartTime(startRaw);

    return BookingServiceItem(
      id: parseInt(json['id']),
      serviceId: parseInt(json['serviceId'] ?? json['id']),
      serviceName: (json['serviceName'] as String?) ??
          (json['name'] as String?) ??
          'Dịch vụ',
      staffId: json['staffId'] == null ? null : parseInt(json['staffId']),
      staffName: json['staffName'] as String?,
      staffAvatarUrl: json['staffAvatarUrl'] as String?,
      appointmentDate: parseDate(json['appointmentDate'] ??
          json['appointmentDateUtc'] ??
          json['date']),
      startTime: start,
      endTime: (json['endTime'] as String?) ?? json['end'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      status: json['status'] is int
          ? json['status'] as int
          : int.tryParse('${json['status']}'),
    );
  }

  factory BookingServiceItem.empty() {
    return BookingServiceItem(
      id: 0,
      serviceId: 0,
      serviceName: '-',
      staffId: null,
      staffName: null,
      staffAvatarUrl: null,
      appointmentDate: DateTime.now(),
      startTime: '-',
      endTime: null,
      price: 0,
      status: null,
    );
  }
}

class BookingPaymentItem {
  final int id;
  final double amount;
  final int paymentMethod;
  final int paymentType;
  final int status;
  final DateTime? paidAt;

  BookingPaymentItem({
    required this.id,
    required this.amount,
    required this.paymentMethod,
    required this.paymentType,
    required this.status,
    this.paidAt,
  });

  factory BookingPaymentItem.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      if (v is String) return DateTime.tryParse(v);
      if (v is DateTime) return v;
      return null;
    }

    int parseInt(dynamic v, [int fallback = 0]) {
      if (v is int) return v;
      if (v is String) return int.tryParse(v) ?? fallback;
      return fallback;
    }

    double parseDouble(dynamic v, [double fallback = 0]) {
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? fallback;
      return fallback;
    }

    return BookingPaymentItem(
      id: parseInt(json['id']),
      amount: parseDouble(json['amount']),
      paymentMethod: parseInt(json['paymentMethod']),
      paymentType: parseInt(json['paymentType']),
      status: parseInt(json['status']),
      paidAt: parseDate(json['paidAt']),
    );
  }

  factory BookingPaymentItem.empty() {
    return BookingPaymentItem(
      id: 0,
      amount: 0,
      paymentMethod: 0,
      paymentType: 0,
      status: 0,
      paidAt: null,
    );
  }

  String get methodText {
    switch (paymentMethod) {
      case 0:
        return 'Momo';
      case 1:
        return 'VNPay';
      case 2:
        return 'COD';
      default:
        return 'Khác';
    }
  }

  String get statusText {
    switch (status) {
      case 0:
        return 'Chờ xử lý';
      case 1:
        return 'Thành công';
      case 2:
        return 'Thất bại';
      case 3:
        return 'Đã hoàn tiền';
      default:
        return 'Không xác định';
    }
  }
}
