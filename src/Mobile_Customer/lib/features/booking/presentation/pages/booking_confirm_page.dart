import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:mobile_customer/features/booking/data/models/booking_detail_request_model.dart';
import 'package:mobile_customer/features/booking/data/models/booking_request_model.dart';
import 'package:mobile_customer/injection/service_locator.dart' as di;

class BookingConfirmPage extends StatefulWidget {
  final int storeId;
  final List<int> services;
  final DateTime appointmentDate;
  final String startTime;
  final int? staffId;
  final String? staffName;

  const BookingConfirmPage({
    super.key,
    required this.storeId,
    required this.services,
    required this.appointmentDate,
    required this.startTime,
    this.staffId,
    this.staffName,
  });

  @override
  State<BookingConfirmPage> createState() => _BookingConfirmPageState();
}

class _BookingConfirmPageState extends State<BookingConfirmPage> {
  bool loading = true;
  bool isSubmitting = false;
  String? error;
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _sub;

  Map<String, dynamic>? storeData;
  List<Map<String, dynamic>> selectedServiceDetails = [];

  List<Map<String, dynamic>> vouchers = [];
  Map<String, dynamic>? appliedVoucher;

  final voucherCodeController = TextEditingController();

  /// PAYMENT METHOD ENUM MAPPING
  /// MoMo = 0
  /// VNPay = 1
  /// COD = 2
  int paymentMethod = 2;

  /// KIỂU THANH TOÁN / CỌC
  /// 0 = Không cọc trước
  /// 1 = Cọc 30%
  /// 2 = Thanh toán toàn bộ
  static const int _payLater = 0;
  static const int _deposit30 = 1;
  static const int _payFull = 2;

  int paymentPlan = _payFull;

  String? customerNote;

  @override
  void initState() {
    super.initState();
    _loadData();
    _handleDeepLink();
  }

  @override
  void dispose() {
    _sub?.cancel(); // QUAN TRỌNG
    voucherCodeController.dispose();
    super.dispose();
  }

  double get subtotal {
    double sum = 0;
    for (final s in selectedServiceDetails) {
      sum += (s['price'] as double);
    }
    return sum;
  }

  int get totalDuration {
    int sum = 0;
    for (final s in selectedServiceDetails) {
      sum += (s['durationMinutes'] as int);
    }
    return sum;
  }

  double computeDiscount() {
    if (appliedVoucher == null) return 0;

    final v = appliedVoucher!;

    final discountType = v['discountType'];
    final discountValue = (v['discountValue'] as num).toDouble();
    final minOrder = (v['minOrderValue'] as num?)?.toDouble() ?? 0;
    final maxDiscount =
        (v['maxDiscount'] as num?)?.toDouble() ?? double.infinity;

    if (subtotal < minOrder) return 0;

    double raw = 0;

    if (discountType == 0) {
      raw = subtotal * (discountValue / 100);
    } else {
      raw = discountValue;
    }

    if (raw > maxDiscount) raw = maxDiscount;

    return raw;
  }

  double get finalTotal {
    final value = subtotal - computeDiscount();
    return value < 0 ? 0 : value;
  }

  bool get isHighValueBooking => finalTotal >= 200000;

  double get depositAmount {
    if (isHighValueBooking) {
      if (paymentPlan == _deposit30) {
        return finalTotal * 0.3;
      }
      return finalTotal;
    }

    if (paymentPlan == _payLater) {
      return 0;
    }

    return finalTotal;
  }

  bool _voucherAppliesToCurrentBooking(Map<String, dynamic> v) {
    final storeId = (v['storeId'] as num?)?.toInt();
    if (storeId != widget.storeId) return false;

    final serviceId = (v['serviceId'] as num?)?.toInt();
    if (serviceId != null && !widget.services.contains(serviceId)) {
      return false;
    }

    final minOrder = (v['minOrderValue'] as num?)?.toDouble() ?? 0;
    return subtotal >= minOrder;
  }

  Future<void> _loadData() async {
    try {
      final dio = di.sl<Dio>();

      final resp = await dio.get('stores/${widget.storeId}');
      storeData = resp.data;

      final servicesFromStore =
          (storeData?['services'] as List).cast<Map<String, dynamic>>();

      selectedServiceDetails = widget.services.map((id) {
        final found = servicesFromStore.where((e) => e['id'] == id).toList();

        if (found.isEmpty) {
          return {
            'id': id,
            'name': 'Dịch vụ #$id',
            'price': 0.0,
            'durationMinutes': 0,
          };
        }

        final s = found.first;

        return {
          'id': s['id'],
          'name': s['name'],
          'price': (s['price'] as num).toDouble(),
          'durationMinutes': s['durationMinutes'],
        };
      }).toList();

      final vresp = await dio.get('voucher/active');
      final vdata = (vresp.data as List).cast<Map<String, dynamic>>();

      vouchers = vdata.where(_voucherAppliesToCurrentBooking).toList();

      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          loading = false;
          error = e.toString();
        });
      }
    }
  }

  Future<void> _applyVoucherByCode() async {
    final code = voucherCodeController.text.trim();

    if (code.isEmpty) return;

    final found = vouchers.where(
      (v) => (v['code'] as String).toUpperCase() == code.toUpperCase(),
    );

    if (found.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Voucher không hợp lệ')),
      );
      return;
    }

    final voucher = found.first;

    if (!_voucherAppliesToCurrentBooking(voucher)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Voucher không áp dụng cho booking này')),
      );
      return;
    }

    setState(() {
      appliedVoucher = voucher;

      if (!isHighValueBooking && paymentPlan == _deposit30) {
        paymentPlan = _payFull;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Áp dụng voucher thành công')),
    );
  }

  void _selectVoucher(Map<String, dynamic>? v) {
    setState(() {
      appliedVoucher = v;

      if (v == null) {
        voucherCodeController.clear();
      }

      if (!isHighValueBooking && paymentPlan == _deposit30) {
        paymentPlan = _payFull;
      }
    });
  }

  Future<void> _confirmAndCreateBooking() async {
    if (isSubmitting) return;

    if (!isHighValueBooking && paymentPlan == _deposit30) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đơn dưới 200000 không áp dụng cọc 30%'),
        ),
      );
      return;
    }

    if (depositAmount <= 0 && paymentMethod != 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không cọc trước chỉ hỗ trợ thanh toán tại cửa hàng'),
        ),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    final details = selectedServiceDetails.map((s) {
      return BookingDetailRequestModel(
        serviceId: s['id'],
        staffId: widget.staffId,
        appointmentDate: widget.appointmentDate,
        startTime: widget.startTime,
      );
    }).toList();

    final model = BookingRequestModel(
      storeId: widget.storeId,
      voucherId: appliedVoucher?['id'],
      customerNote: customerNote,
      paymentMethod: paymentMethod,
      depositAmount: depositAmount,
      services: details,
    );

    try {
      final dio = di.sl<Dio>();

      final bookingResp = await dio.post('bookings', data: model.toJson());
      final bookingId = bookingResp.data['id'];

      if (paymentMethod == 1) {
        final amountToPay = depositAmount.round();

        if (amountToPay <= 0) {
          throw Exception("Không có số tiền cần thanh toán ngay");
        }

        final paymentResp = await dio.post(
          'payments/vnpay/create',
          data: {
            "orderId": "BOOKING_$bookingId",
            "amount": amountToPay,
            "orderInfo": "Thanh toan booking $bookingId",
          },
        );

        final paymentUrl = paymentResp.data['url'];
        final uri = Uri.parse(paymentUrl);

        if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
          throw Exception("Không mở được VNPAY");
        }

        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đặt lịch thành công')),
      );

      Navigator.popUntil(context, (route) => route.isFirst);
    } on DioException catch (e) {
      final message = e.response?.data ?? e.message;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $message')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  void _handleDeepLink() async {
    _appLinks = AppLinks();

    // app mở từ link
    final uri = await _appLinks.getInitialAppLink();
    if (uri != null) {
      _handleUri(uri);
    }

    // app đang chạy
    _sub = _appLinks.uriLinkStream.listen((uri) {
      _handleUri(uri);
    });
  }

  bool _handledPayment = false;

  void _handleUri(Uri uri) {
    if (_handledPayment) return;

    if (uri.scheme == 'myapp' && uri.host == 'payment-result') {
      _handledPayment = true;

      final status = uri.queryParameters['status'];

      if (status == 'success') {
        _onPaymentSuccess();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thanh toán thất bại')),
        );
      }
    }
  }

  void _onPaymentSuccess() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã thanh toán & đặt lịch thành công')),
    );

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/booking',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFF7FB),
                Color(0xFFFFEEF5),
                Color(0xFFFFFFFF),
              ],
            ),
          ),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (error != null) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFF7FB),
                Color(0xFFFFEEF5),
                Color(0xFFFFFFFF),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Row(
                    children: [
                      _backButton(context),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Xác nhận đặt lịch',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF4A4A4A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final dateLabel = DateFormat('dd/MM/yyyy').format(widget.appointmentDate);
    final discount = computeDiscount();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF7FB),
              Color(0xFFFFEEF5),
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Row(
                  children: [
                    _backButton(context),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Xác nhận đặt lịch',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF4A4A4A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _iconCircle(
                      icon: Icons.receipt_long_rounded,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: [
                    _sectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF1F6),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: const Icon(
                                  Icons.storefront_rounded,
                                  color: Color(0xFFE85E9C),
                                  size: 30,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      storeData?['name'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF1F1F24),
                                        height: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      storeData?['address'] ?? '',
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        height: 1.4,
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _metricTile(
                                  icon: Icons.calendar_month_rounded,
                                  label: 'Ngày hẹn',
                                  value: dateLabel,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _metricTile(
                                  icon: Icons.schedule_rounded,
                                  label: 'Giờ hẹn',
                                  value: widget.startTime,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _metricTile(
                                  icon: Icons.timelapse_rounded,
                                  label: 'Tổng thời gian',
                                  value: '$totalDuration phút',
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _metricTile(
                                  icon: widget.staffId == null
                                      ? Icons.person_outline_rounded
                                      : Icons.person_rounded,
                                  label: 'Nhân viên',
                                  value: widget.staffId == null
                                      ? 'Bất kỳ'
                                      : (widget.staffName ?? ''),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _sectionHeader('Dịch vụ'),
                    const SizedBox(height: 10),
                    ...selectedServiceDetails.map((s) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: const Color(0xFFFFDDE8)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          title: Text(
                            s['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1F1F24),
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              '${s['durationMinutes']} phút',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          trailing: Text(
                            '${(s['price'] as double).toStringAsFixed(0)} VND',
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFE85E9C),
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 6),
                    _sectionHeader('Voucher'),
                    const SizedBox(height: 10),
                    _sectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (vouchers.isNotEmpty) ...[
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: vouchers.map((v) {
                                final selected = appliedVoucher != null &&
                                    appliedVoucher!['id'] == v['id'];

                                return ChoiceChip(
                                  label: Text(v['code']),
                                  selected: selected,
                                  onSelected: (_) =>
                                      _selectVoucher(selected ? null : v),
                                  selectedColor: const Color(0xFFFF6FAF),
                                  labelStyle: TextStyle(
                                    color: selected
                                        ? Colors.white
                                        : const Color(0xFF3A3A40),
                                    fontWeight: FontWeight.w700,
                                  ),
                                  backgroundColor: const Color(0xFFFFFBFD),
                                  side: BorderSide(
                                    color: selected
                                        ? const Color(0xFFFF6FAF)
                                        : const Color(0xFFFFDDE8),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 14),
                          ],
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: voucherCodeController,
                                  decoration: InputDecoration(
                                    labelText: "Nhập mã voucher",
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFFFDDE8),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFFFDDE8),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFFF6FAF),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                height: 54,
                                child: ElevatedButton(
                                  onPressed: _applyVoucherByCode,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFF6FAF),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    "Áp dụng",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _sectionHeader('Kiểu thanh toán'),
                    const SizedBox(height: 10),
                    _sectionCard(
                      child: Column(
                        children: [
                          if (isHighValueBooking) ...[
                            _paymentTile(
                              value: _deposit30,
                              groupValue: paymentPlan,
                              title: "Cọc 30%",
                              subtitle: Text(
                                "Thanh toán ngay ${(finalTotal * 0.3).toStringAsFixed(0)} VND",
                              ),
                              onChanged: (v) =>
                                  setState(() => paymentPlan = v!),
                            ),
                            const SizedBox(height: 8),
                            _paymentTile(
                              value: _payFull,
                              groupValue: paymentPlan,
                              title: "Thanh toán toàn bộ",
                              subtitle: Text(
                                "Thanh toán ngay ${finalTotal.toStringAsFixed(0)} VND",
                              ),
                              onChanged: (v) =>
                                  setState(() => paymentPlan = v!),
                            ),
                          ] else ...[
                            _paymentTile(
                              value: _payLater,
                              groupValue: paymentPlan,
                              title: "Không cọc trước",
                              subtitle: const Text("Thanh toán tại cửa hàng"),
                              onChanged: (v) =>
                                  setState(() => paymentPlan = v!),
                            ),
                            const SizedBox(height: 8),
                            _paymentTile(
                              value: _payFull,
                              groupValue: paymentPlan,
                              title: "Thanh toán toàn bộ",
                              subtitle: Text(
                                "Thanh toán ngay ${finalTotal.toStringAsFixed(0)} VND",
                              ),
                              onChanged: (v) =>
                                  setState(() => paymentPlan = v!),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _sectionHeader('Phương thức thanh toán'),
                    const SizedBox(height: 10),
                    _sectionCard(
                      child: Column(
                        children: [
                          _paymentMethodTile(
                            value: 2,
                            groupValue: paymentMethod,
                            title: "Tiền mặt (COD)",
                            icon: Icons.payments_outlined,
                            onChanged: (v) =>
                                setState(() => paymentMethod = v!),
                          ),
                          const SizedBox(height: 8),
                          _paymentMethodTile(
                            value: 0,
                            groupValue: paymentMethod,
                            title: "MoMo",
                            icon: Icons.account_balance_wallet_outlined,
                            onChanged: (v) =>
                                setState(() => paymentMethod = v!),
                          ),
                          const SizedBox(height: 8),
                          _paymentMethodTile(
                            value: 1,
                            groupValue: paymentMethod,
                            title: "VNPay",
                            icon: Icons.credit_card_rounded,
                            onChanged: (v) =>
                                setState(() => paymentMethod = v!),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _sectionHeader('Ghi chú'),
                    const SizedBox(height: 10),
                    _sectionCard(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: "Ghi chú cho cửa hàng",
                          alignLabelWithHint: true,
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xFFFFDDE8),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xFFFFDDE8),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xFFFF6FAF),
                            ),
                          ),
                        ),
                        maxLines: 3,
                        onChanged: (v) => customerNote = v,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _sectionHeader('Tổng kết'),
                    const SizedBox(height: 10),
                    _sectionCard(
                      child: Column(
                        children: [
                          _summaryRow(
                            label: 'Tổng giá gốc',
                            value: '${subtotal.toStringAsFixed(0)} VND',
                          ),
                          const SizedBox(height: 10),
                          _summaryRow(
                            label: 'Giảm giá',
                            value: '- ${discount.toStringAsFixed(0)} VND',
                            valueColor: const Color(0xFFE25555),
                          ),
                          const SizedBox(height: 10),
                          _summaryRow(
                            label: 'Tổng sau giảm giá',
                            value: '${finalTotal.toStringAsFixed(0)} VND',
                          ),
                          const SizedBox(height: 10),
                          _summaryRow(
                            label: 'Số tiền cần thanh toán ngay',
                            value: '${depositAmount.toStringAsFixed(0)} VND',
                            valueColor: const Color(0xFFE85E9C),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.96),
            border: const Border(
              top: BorderSide(color: Color(0xFFFFDDE8)),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 18,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _summaryTile(
                      label: 'Tổng thanh toán',
                      value: '${depositAmount.toStringAsFixed(0)} VND',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _summaryTile(
                      label: 'Phương thức',
                      value: paymentMethod == 2
                          ? 'COD'
                          : paymentMethod == 0
                              ? 'MoMo'
                              : 'VNPay',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : _confirmAndCreateBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6FAF),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFFFC7DC),
                    disabledForegroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 0,
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          "Xác nhận đặt lịch",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Color(0xFF1F1F24),
        ),
      ),
    );
  }

  Widget _sectionCard({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFFDDE8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _summaryRow({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w800,
            color: valueColor ?? const Color(0xFF1F1F24),
          ),
        ),
      ],
    );
  }

  Widget _summaryTile({
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBFD),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFE1EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F1F24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBFD),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFE1EC)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 20,
              color: const Color(0xFFE85E9C),
            ),
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
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentTile<T>({
    required T value,
    required T groupValue,
    required String title,
    required Widget subtitle,
    required ValueChanged<T?> onChanged,
  }) {
    final selected = value == groupValue;

    return Container(
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFFFF4F8) : const Color(0xFFFFFBFD),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selected ? const Color(0xFFFFB8D3) : const Color(0xFFFFDDE8),
          width: selected ? 1.2 : 1,
        ),
      ),
      child: RadioListTile<T>(
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        activeColor: const Color(0xFFFF6FAF),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF1F1F24),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: DefaultTextStyle(
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
            child: subtitle,
          ),
        ),
      ),
    );
  }

  Widget _paymentMethodTile<T>({
    required T value,
    required T groupValue,
    required String title,
    required IconData icon,
    required ValueChanged<T?> onChanged,
  }) {
    final selected = value == groupValue;

    return Container(
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFFFF4F8) : const Color(0xFFFFFBFD),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selected ? const Color(0xFFFFB8D3) : const Color(0xFFFFDDE8),
          width: selected ? 1.2 : 1,
        ),
      ),
      child: RadioListTile<T>(
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        activeColor: const Color(0xFFFF6FAF),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 20,
                color: const Color(0xFFE85E9C),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F1F24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _backButton(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFFD1E3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 16,
          color: Color(0xFFFF6FAF),
        ),
      ),
    );
  }

  Widget _iconCircle({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFD1E3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 18,
            color: const Color(0xFFE85E9C),
          ),
        ),
      ),
    );
  }
}
