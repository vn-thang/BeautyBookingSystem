import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';

import 'package:mobile_customer/injection/service_locator.dart' as di;

/// Booking list + detail (with payments)
class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  bool _loading = true;
  String? _error;
  List<BookingItem> _bookings = [];

  final String _bookingsEndpoint = 'bookings';

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final dio = di.sl<Dio>();
      final resp = await dio.get(_bookingsEndpoint);
      final data = resp.data;

      List<dynamic> items = [];
      if (data is List) {
        items = data;
      } else if (data is Map && data['items'] is List) {
        items = data['items'];
      } else if (data is Map && data['data'] is List) {
        items = data['data'];
      } else {
        items = data != null ? [data] : [];
      }

      final parsed = items
          .map((e) => BookingItem.fromJson(e as Map<String, dynamic>))
          .toList();

      setState(() {
        _bookings = parsed;
        _loading = false;
      });
    } on DioError catch (e) {
      setState(() {
        _loading = false;
        _error = e.response?.data?.toString() ?? e.message;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _onRefresh() async {
    await _loadBookings();
  }

  Future<void> _openBookingDetail(BookingItem item) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SizedBox(
        height: 160,
        child: Center(child: CircularProgressIndicator()),
      ),
    );

    try {
      final dio = di.sl<Dio>();
      final resp = await dio.get('bookings/${item.id}');
      final data = resp.data as Map<String, dynamic>;
      final full = BookingItem.fromJson(data);

      if (Navigator.canPop(context)) Navigator.pop(context);

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => BookingDetailSheet(
          item: full,
          onCancel: () async {},
        ),
      );
    } catch (e) {
      if (Navigator.canPop(context)) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không tải được chi tiết booking: $e')),
      );
    }
  }

  int get _pendingCount => _bookings.where((e) => e.status == 0).length;
  int get _confirmedCount => _bookings.where((e) => e.status == 1).length;
  int get _completedCount => _bookings.where((e) => e.status == 2).length;
  int get _cancelledCount => _bookings.where((e) => e.status == 3).length;

  double get _totalSpent =>
      _bookings.fold(0.0, (sum, item) => sum + item.finalPrice);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF8FC),
              Color(0xFFFFF1F7),
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFFFD6E6)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 17,
                          color: Color(0xFFFF6FAF),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Lịch đặt của tôi',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF202024),
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Theo dõi booking, thanh toán và trạng thái đơn',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: const Color(0xFFFFD6E6)),
                      ),
                      child: Text(
                        '${_bookings.length}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFFF6FAF),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? _buildError()
                        : _bookings.isEmpty
                            ? _buildEmpty()
                            : RefreshIndicator(
                                onRefresh: _onRefresh,
                                child: ListView(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 4, 16, 16),
                                  children: [
                                    _buildSummaryPanel(),
                                    const SizedBox(height: 16),
                                    ListView.separated(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: _bookings.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(height: 12),
                                      itemBuilder: (context, index) {
                                        final b = _bookings[index];

                                        final firstService =
                                            b.services.isNotEmpty
                                                ? b.services.first
                                                : null;
                                        final dateLabel = firstService != null
                                            ? DateFormat('dd/MM/yyyy').format(
                                                firstService.appointmentDate)
                                            : (b.createdAt != null
                                                ? DateFormat('dd/MM/yyyy')
                                                    .format(b.createdAt!)
                                                : '-');
                                        final timeLabel =
                                            firstService?.startTime ?? '-';

                                        final subtitleText =
                                            b.services.isNotEmpty
                                                ? b.serviceNamesSummary()
                                                : (b.storeName ?? '-');

                                        return _buildBookingCard(
                                          item: b,
                                          subtitleText: subtitleText,
                                          dateLabel: dateLabel,
                                          timeLabel: timeLabel,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFFFF3F8),
          ],
        ),
        border: Border.all(color: const Color(0xFFFFD9E6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.event_note_rounded, color: Color(0xFFFF6FAF)),
              SizedBox(width: 8),
              Text(
                'Tổng quan booking',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF202024),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _summaryChip(
                  icon: Icons.schedule_rounded,
                  label: 'Chờ xác nhận',
                  value: _pendingCount,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _summaryChip(
                  icon: Icons.verified_rounded,
                  label: 'Đã xác nhận',
                  value: _confirmedCount,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _summaryChip(
                  icon: Icons.check_circle_rounded,
                  label: 'Hoàn thành',
                  value: _completedCount,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _summaryChip(
                  icon: Icons.payments_rounded,
                  label: 'Đã chi tiêu',
                  value: _totalSpent.toInt(),
                  suffix: ' VND',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryChip({
    required IconData icon,
    required String label,
    required int value,
    String suffix = '',
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFE0EC)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFFFEEF5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFFFF6FAF)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$value$suffix',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF202024),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard({
    required BookingItem item,
    required String subtitleText,
    required String dateLabel,
    required String timeLabel,
  }) {
    final statusInfo = _statusInfo(item.status);
    final firstService = item.services.isNotEmpty ? item.services.first : null;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFFFF7FA),
          ],
        ),
        border: Border.all(
          color: const Color(0xFFFFD9E6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openBookingDetail(item),
          borderRadius: BorderRadius.circular(26),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 10,
                  height: 92,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        statusInfo.color.withOpacity(0.95),
                        statusInfo.color.withOpacity(0.55),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              item.storeName?.trim().isNotEmpty == true
                                  ? item.storeName!
                                  : 'Mã booking #${item.id}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1F1F24),
                                height: 1.25,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: statusInfo.color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: statusInfo.color.withOpacity(0.25),
                              ),
                            ),
                            child: Text(
                              statusInfo.label,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: statusInfo.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitleText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.2,
                          height: 1.35,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _metaPill(
                            icon: Icons.calendar_month_rounded,
                            text: '$dateLabel • $timeLabel',
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _metaPill(
                            icon: Icons.receipt_long_rounded,
                            text: 'Mã #${item.id}',
                          ),
                          const SizedBox(width: 8),
                          if (firstService != null)
                            _metaPill(
                              icon: Icons.content_cut_rounded,
                              text: '${item.services.length} dịch vụ',
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${item.finalPrice.toStringAsFixed(0)} VND',
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F1F24),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Cọc ${item.depositAmount.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEEF5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFFFF6FAF),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _metaPill({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFFFDCE8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFFFF6FAF)),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3A3A40),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.88),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFFFFD6E6)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEEF5),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6FAF).withOpacity(0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  size: 46,
                  color: Color(0xFFFF6FAF),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Bạn chưa có lịch đặt nào',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2B2B30),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Hãy khám phá dịch vụ phù hợp và đặt lịch ngay để bắt đầu.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6FAF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Tìm dịch vụ',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFFFD6E6)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEEF5),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6FAF).withOpacity(0.10),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  size: 42,
                  color: Color(0xFFFF6FAF),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Không thể tải lịch đặt',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2B2B30),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _error ?? 'Đã xảy ra lỗi không xác định.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loadBookings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6FAF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Thử lại',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ({String label, Color color}) _statusInfo(int status) {
    switch (status) {
      case 0:
        return (label: 'Chờ xác nhận', color: Colors.orange);
      case 1:
        return (label: 'Đã xác nhận', color: Colors.green);
      case 2:
        return (label: 'Hoàn thành', color: Colors.blue);
      case 3:
        return (label: 'Đã hủy', color: Colors.red);
      default:
        return (label: 'Không rõ', color: Colors.grey);
    }
  }
}

/// Booking item UI model (supports both summary and detail responses)
class BookingItem {
  final int id;
  final DateTime? createdAt;
  final double totalPrice;
  final double discountAmount;
  final double depositAmount;
  final double finalPrice;
  final int status;
  final String? customerNote;
  final String? storeName;
  final List<BookingServiceItem> services;
  final List<BookingPaymentItem> payments;

  BookingItem({
    required this.id,
    this.createdAt,
    required this.totalPrice,
    required this.discountAmount,
    required this.depositAmount,
    required this.finalPrice,
    required this.status,
    this.customerNote,
    this.storeName,
    required this.services,
    required this.payments,
  });

  factory BookingItem.fromJson(Map<String, dynamic> json) {
    DateTime? parseCreated(dynamic v) {
      if (v == null) return null;
      if (v is String) return DateTime.tryParse(v);
      if (v is DateTime) return v;
      return null;
    }

    final servicesJson = (json['services'] as List?) ??
        (json['items'] is List ? json['items'] as List : null) ??
        [];
    final svc = (servicesJson as List).map((e) {
      try {
        return BookingServiceItem.fromJson(e as Map<String, dynamic>);
      } catch (_) {
        return BookingServiceItem.empty();
      }
    }).toList();

    final paymentsJson = (json['payments'] as List?) ?? [];
    final pay = (paymentsJson as List).map((e) {
      try {
        return BookingPaymentItem.fromJson(e as Map<String, dynamic>);
      } catch (_) {
        return BookingPaymentItem.empty();
      }
    }).toList();

    return BookingItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      createdAt: parseCreated(json['createdAt']),
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0,
      depositAmount: (json['depositAmount'] as num?)?.toDouble() ?? 0,
      finalPrice: (json['finalPrice'] as num?)?.toDouble() ?? 0,
      status: (json['status'] is int)
          ? (json['status'] as int)
          : ((json['status'] is String)
              ? int.tryParse(json['status']) ?? 0
              : 0),
      customerNote: json['customerNote'] as String?,
      storeName: json['storeName'] as String?,
      services: svc,
      payments: pay,
    );
  }

  double get paidAmount {
    return payments
        .where((p) => p.status == 1)
        .fold(0.0, (sum, p) => sum + p.amount);
  }

  double get remainingAmount {
    final remaining = finalPrice - paidAmount;
    return remaining < 0 ? 0 : remaining;
  }

  String serviceNamesSummary() {
    if (services.isEmpty) return '-';
    final names = services.map((s) => s.serviceName).toList();
    return names.join(', ');
  }

  String get statusText {
    switch (status) {
      case 0:
        return "Pending";
      case 1:
        return "Confirmed";
      case 2:
        return "Completed";
      case 3:
        return "Cancelled";
      default:
        return "Unknown";
    }
  }
}

/// Booking service item
class BookingServiceItem {
  final int serviceId;
  final String serviceName;
  final int? staffId;
  final DateTime appointmentDate;
  final String startTime;
  final String? endTime;
  final double price;
  final int? status;

  BookingServiceItem({
    required this.serviceId,
    required this.serviceName,
    this.staffId,
    required this.appointmentDate,
    required this.startTime,
    this.endTime,
    required this.price,
    this.status,
  });

  factory BookingServiceItem.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is String) {
        return DateTime.tryParse(v) ?? DateTime.now();
      }
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

    final startRaw =
        (json['startTime'] as String?) ?? (json['start'] as String?) ?? '';
    final start = normalizeStartTime(startRaw);

    return BookingServiceItem(
      serviceId: (json['serviceId'] as num?)?.toInt() ??
          (json['id'] as num?)?.toInt() ??
          0,
      serviceName: (json['serviceName'] as String?) ??
          (json['name'] as String?) ??
          'Dịch vụ',
      staffId: (json['staffId'] as num?)?.toInt(),
      appointmentDate: parseDate(
        json['appointmentDate'] ?? json['appointmentDateUtc'] ?? json['date'],
      ),
      startTime: start,
      endTime: (json['endTime'] as String?) ?? null,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      status: (json['status'] as int?) ??
          (json['status'] is String ? int.tryParse(json['status']) : null),
    );
  }

  factory BookingServiceItem.empty() {
    return BookingServiceItem(
      serviceId: 0,
      serviceName: '-',
      staffId: null,
      appointmentDate: DateTime.now(),
      startTime: '-',
      endTime: null,
      price: 0,
      status: null,
    );
  }
}

/// Payment item
class BookingPaymentItem {
  final int id;
  final double amount;
  final int paymentMethod;
  final int status;
  final DateTime? paidAt;

  BookingPaymentItem({
    required this.id,
    required this.amount,
    required this.paymentMethod,
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

    return BookingPaymentItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      paymentMethod: (json['paymentMethod'] as int?) ??
          (json['paymentMethod'] is String
              ? int.tryParse(json['paymentMethod']) ?? 0
              : 0),
      status: (json['status'] as int?) ?? 0,
      paidAt: parseDate(json['paidAt']),
    );
  }

  factory BookingPaymentItem.empty() {
    return BookingPaymentItem(
      id: 0,
      amount: 0,
      paymentMethod: 0,
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
        return 'Pending';
      case 1:
        return 'Paid';
      case 2:
        return 'Failed';
      case 3:
        return 'Refunded';
      default:
        return 'Unknown';
    }
  }
}

/// Bottom sheet to show booking details + payments
class BookingDetailSheet extends StatelessWidget {
  final BookingItem item;
  final VoidCallback? onCancel;

  const BookingDetailSheet({super.key, required this.item, this.onCancel});

  @override
  Widget build(BuildContext context) {
    final dateLabel = item.services.isNotEmpty
        ? DateFormat('dd/MM/yyyy').format(item.services.first.appointmentDate)
        : (item.createdAt != null
            ? DateFormat('dd/MM/yyyy').format(item.createdAt!)
            : '-');
    final timeLabel =
        item.services.isNotEmpty ? item.services.first.startTime : '-';

    final statusInfo = _statusInfo(item.status);

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.only(top: 24),
        decoration: const BoxDecoration(
          color: Color(0xFFFDFBFC),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.88,
          minChildSize: 0.55,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFFFF3F8),
                            Color(0xFFFFFFFF),
                          ],
                        ),
                        border: Border.all(color: const Color(0xFFFFD9E6)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Booking #${item.id}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1F1F24),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: statusInfo.color.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: statusInfo.color.withOpacity(0.25),
                                  ),
                                ),
                                child: Text(
                                  statusInfo.label,
                                  style: TextStyle(
                                    color: statusInfo.color,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            item.storeName ?? '-',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _infoPill(
                                icon: Icons.calendar_today_rounded,
                                text: '$dateLabel • $timeLabel',
                              ),
                              const SizedBox(width: 8),
                              _infoPill(
                                icon: Icons.receipt_long_rounded,
                                text: 'Mã #${item.id}',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _sectionTitle('Dịch vụ'),
                    const SizedBox(height: 8),
                    _sectionCard(
                      child: item.services.isEmpty
                          ? const Text('-')
                          : Column(
                              children: item.services.map((s) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: const Color(0xFFFFE0EC),
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFEEF5),
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        child: const Icon(
                                          Icons.content_cut_rounded,
                                          color: Color(0xFFFF6FAF),
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              s.serviceName,
                                              style: const TextStyle(
                                                fontSize: 14.5,
                                                fontWeight: FontWeight.w800,
                                                color: Color(0xFF1F1F24),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Ngày: ${DateFormat('dd/MM/yyyy').format(s.appointmentDate)}',
                                              style: TextStyle(
                                                fontSize: 12.5,
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                            if (s.startTime.isNotEmpty) ...[
                                              const SizedBox(height: 3),
                                              Text(
                                                'Giờ: ${s.startTime}',
                                                style: TextStyle(
                                                  fontSize: 12.5,
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        '${s.price.toStringAsFixed(0)} VND',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF1F1F24),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                    ),
                    const SizedBox(height: 14),
                    _sectionTitle('Thanh toán'),
                    const SizedBox(height: 8),
                    _sectionCard(
                      child: Column(
                        children: [
                          _priceLine('Tổng giá gốc', item.totalPrice),
                          _priceLine('Giảm giá', -item.discountAmount),
                          _priceLine('Tổng sau giảm', item.finalPrice,
                              bold: true),
                          _priceLine('Đã cọc', item.depositAmount),
                          _priceLine('Đã thanh toán', item.paidAmount),
                          const Divider(height: 24),
                          _priceLine(
                            'Còn lại phải thanh toán',
                            item.remainingAmount,
                            bold: true,
                            highlight: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _sectionTitle('Giao dịch'),
                    const SizedBox(height: 8),
                    _sectionCard(
                      child: item.payments.isEmpty
                          ? const Text('-')
                          : Column(
                              children: item.payments.map((p) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: const Color(0xFFFFE0EC),
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFEEF5),
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        child: const Icon(
                                          Icons.payments_rounded,
                                          color: Color(0xFFFF6FAF),
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${p.methodText} • ${p.amount.toStringAsFixed(0)} VND',
                                              style: const TextStyle(
                                                fontSize: 14.5,
                                                fontWeight: FontWeight.w800,
                                                color: Color(0xFF1F1F24),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              p.statusText +
                                                  (p.paidAt != null
                                                      ? ' • ${DateFormat('dd/MM/yyyy HH:mm').format(p.paidAt!)}'
                                                      : ''),
                                              style: TextStyle(
                                                fontSize: 12.5,
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius:
                                              BorderRadius.circular(999),
                                        ),
                                        child: Text(
                                          p.statusText,
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.grey.shade800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6FAF),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Đóng',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        if (onCancel != null) ...[
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                onCancel?.call();
                              },
                              child: const Text(
                                'Hủy',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: Color(0xFF1F1F24),
        ),
      ),
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withOpacity(0.95),
        border: Border.all(color: const Color(0xFFFFD9E6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _priceLine(
    String label,
    double value, {
    bool bold = false,
    bool highlight = false,
  }) {
    final isNegative = value < 0;
    final displayValue = value.abs().toStringAsFixed(0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
                color: highlight
                    ? const Color(0xFFFF6FAF)
                    : const Color(0xFF3A3A40),
              ),
            ),
          ),
          Text(
            '${isNegative ? '-' : ''}$displayValue VND',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              color:
                  highlight ? const Color(0xFFFF6FAF) : const Color(0xFF1F1F24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoPill({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.94),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFFFDCE8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFFFF6FAF)),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3A3A40),
            ),
          ),
        ],
      ),
    );
  }

  ({String label, Color color}) _statusInfo(int status) {
    switch (status) {
      case 0:
        return (label: 'Chờ xác nhận', color: Colors.orange);
      case 1:
        return (label: 'Đã xác nhận', color: Colors.green);
      case 2:
        return (label: 'Hoàn thành', color: Colors.blue);
      case 3:
        return (label: 'Đã hủy', color: Colors.red);
      default:
        return (label: 'Không rõ', color: Colors.grey);
    }
  }
}
