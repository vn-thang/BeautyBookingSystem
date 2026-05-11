import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:mobile_customer/features/booking/data/models/booking_detail_request_model.dart';
import 'package:mobile_customer/features/booking/data/models/booking_request_model.dart';
import 'package:mobile_customer/injection/service_locator.dart' as di;

import 'package:mobile_customer/core/theme/app_colors.dart';
import 'package:mobile_customer/core/theme/app_decorations.dart';
import 'package:mobile_customer/core/theme/app_text_styles.dart';

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
  static const int _payLater = 0; // COD
  static const int _payFull = 1; // VNPay full
  static const int _deposit = 2; // VNPay deposit

  final NumberFormat _moneyFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'đ',
    decimalDigits: 0,
  );

  bool loading = true;
  bool isSubmitting = false;
  String? error;

  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _sub;
  bool _handledPayment = false;
  bool _waitingForPayment = false;

  Map<String, dynamic>? storeData;
  List<Map<String, dynamic>> selectedServiceDetails = [];

  List<Map<String, dynamic>> vouchers = [];
  Map<String, dynamic>? appliedVoucher;

  final voucherCodeController = TextEditingController();

  int paymentPlan = _payLater;
  String? customerNote;

  bool _loadingBookingPolicy = false;
  bool _isBookingBlocked = false;
  int _currentNoShowCount = 0;
  int _noShowLimit = 0;
  String? _blockReason;

  bool get _canConfirmBooking =>
      !isSubmitting && !loading && !_loadingBookingPolicy && !_isBookingBlocked;
  static const String _vnpayCheckoutBaseUrl =
      'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html';

  String _normalizePaymentUrl(String rawUrl) {
    final url = rawUrl.trim();

    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    if (url.startsWith('?')) {
      return '$_vnpayCheckoutBaseUrl$url';
    }

    if (url.startsWith('/')) {
      return '$_vnpayCheckoutBaseUrl$url';
    }

    return '$_vnpayCheckoutBaseUrl?$url';
  }

  Future<void> _openPaymentUrl(String rawUrl) async {
    final fullUrl = _normalizePaymentUrl(rawUrl);
    final uri = Uri.tryParse(fullUrl);

    if (uri == null) {
      throw Exception('URL thanh toán không hợp lệ');
    }

    final ok = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!ok) {
      throw Exception('Không mở được VNPay');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadBookingPolicy();
    _handleDeepLink();
  }

  @override
  void dispose() {
    _sub?.cancel();
    voucherCodeController.dispose();
    super.dispose();
  }

  String _formatMoney(num value) => _moneyFormat.format(value);

  Map<String, dynamic>? _serviceById(int id) {
    for (final s in selectedServiceDetails) {
      if ((s['id'] as int) == id) return s;
    }
    return null;
  }

  double get subtotal {
    double sum = 0;
    for (final s in selectedServiceDetails) {
      sum += (s['price'] as num).toDouble();
    }
    return sum;
  }

  int get totalDuration {
    int sum = 0;
    for (final s in selectedServiceDetails) {
      sum += (s['durationMinutes'] as num).toInt();
    }
    return sum;
  }

  double _voucherBaseAmount(Map<String, dynamic> voucher) {
    final serviceId = (voucher['serviceId'] as num?)?.toInt();
    if (serviceId == null) return subtotal;
    final service = _serviceById(serviceId);
    if (service == null) return 0;

    return (service['price'] as num).toDouble();
  }

  bool _voucherAppliesToCurrentBooking(Map<String, dynamic> voucher) {
    final baseAmount = _voucherBaseAmount(voucher);
    if (baseAmount <= 0) return false;

    final minOrder = (voucher['minOrderValue'] as num?)?.toDouble() ?? 0;
    return baseAmount >= minOrder;
  }

  double _calculatePotentialDiscount(Map<String, dynamic> voucher) {
    if (!_voucherAppliesToCurrentBooking(voucher)) return 0;

    final baseAmount = _voucherBaseAmount(voucher);
    final discountType = voucher['discountType'];
    final discountValue = (voucher['discountValue'] as num).toDouble();
    final maxDiscount =
        (voucher['maxDiscount'] as num?)?.toDouble() ?? double.infinity;

    double raw = 0;
    if (discountType == 0) {
      raw = baseAmount * (discountValue / 100);
    } else {
      raw = discountValue;
    }

    if (raw > maxDiscount) raw = maxDiscount;
    return raw;
  }

  double computeDiscount() {
    if (appliedVoucher == null) return 0;
    return _calculatePotentialDiscount(appliedVoucher!);
  }

  double get finalTotal {
    final value = subtotal - computeDiscount();
    return value < 0 ? 0 : value;
  }

  int get storeDepositPercent {
    final val = storeData?['depositPercent'];
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val) ?? 0;
    return 0; 
  }

  double get storeDepositThreshold {
    final val = storeData?['depositThreshold'];
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0; 
  }

  bool get allowCashOnDelivery => finalTotal < storeDepositThreshold;
  bool get allowDeposit =>
      finalTotal >= storeDepositThreshold && storeDepositPercent > 0;

  int get paymentMethod => paymentPlan == _payLater ? 2 : 1;

  double get depositAmount {
    if (paymentPlan == _deposit) {
      return finalTotal * (storeDepositPercent / 100);
    }
    return 0;
  }

  double get amountToPayNow {
    if (paymentPlan == _payLater) {
      return 0;
    }
    if (paymentPlan == _deposit) {
      return finalTotal * (storeDepositPercent / 100);
    }
    return finalTotal; 
  }

  void _normalizePaymentPlan() {
    if (!allowCashOnDelivery && paymentPlan == _payLater) {
      paymentPlan = _payFull;
    }

    if (!allowDeposit && paymentPlan == _deposit) {
      paymentPlan = _payFull;
    }
  }

  bool _isFailureResponse(dynamic data) {
    return data is Map && data['success'] == false;
  }

  String _extractErrorMessage(dynamic data,
      {String fallback = 'Yêu cầu thất bại'}) {
    if (data is Map) {
      final message = data['message'];
      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString();
      }
    }
    return data?.toString() ?? fallback;
  }

  Future<void> _loadBookingPolicy() async {
    setState(() {
      _loadingBookingPolicy = true;
    });

    try {
      final dio = di.sl<Dio>();
      final resp = await dio.get('public/system-configs/booking-policies');

      final data = resp.data;
      if (data is Map<String, dynamic>) {
        final policy = data['data'];
        if (policy is Map<String, dynamic> && mounted) {
          setState(() {
            _isBookingBlocked = policy['isBookingBlocked'] == true;
            _currentNoShowCount = policy['currentNoShowCount'] ?? 0;
            _noShowLimit = policy['noShowLimit'] ?? 0;
            _blockReason = policy['blockReason']?.toString();
            _loadingBookingPolicy = false;
          });
          return;
        }
      }

      if (mounted) {
        setState(() {
          _loadingBookingPolicy = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadingBookingPolicy = false;
        });
      }
    }
  }

  Future<int> _createBookingAndGetId(Dio dio, BookingRequestModel model) async {
    final bookingResp = await dio.post('bookings', data: model.toJson());
    final data = bookingResp.data;

    if (_isFailureResponse(data)) {
      throw Exception(
          _extractErrorMessage(data, fallback: 'Đặt lịch thất bại'));
    }

    if (data is! Map) {
      throw Exception('Phản hồi đặt lịch không hợp lệ');
    }

    final rawBookingId = data['id'];
    final bookingId = rawBookingId is num
        ? rawBookingId.toInt()
        : int.tryParse(rawBookingId?.toString() ?? '');

    if (bookingId == null || bookingId <= 0) {
      throw Exception('Không nhận được bookingId');
    }

    final verifyResp = await dio.get('bookings/$bookingId');
    if (verifyResp.statusCode != 200) {
      throw Exception('Booking chưa được lưu thành công');
    }

    return bookingId;
  }

  Future<void> _loadData() async {
    try {
      final dio = di.sl<Dio>();

      final resp = await dio.get('customer/stores/${widget.storeId}');
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
          'durationMinutes': (s['durationMinutes'] as num).toInt(),
        };
      }).toList();

      final vresp = await dio.get('voucher/store/${widget.storeId}/active');
      final vdata = (vresp.data as List).cast<Map<String, dynamic>>();

      vouchers = vdata;

      vouchers.sort((a, b) {
        bool canUseA = _voucherAppliesToCurrentBooking(a);
        bool canUseB = _voucherAppliesToCurrentBooking(b);

        if (canUseA && !canUseB) return -1;
        if (!canUseA && canUseB) return 1;

        if (canUseA && canUseB) {
          double discountA = _calculatePotentialDiscount(a);
          double discountB = _calculatePotentialDiscount(b);
          return discountB.compareTo(discountA); 
        }

        return 0;
      });

      if (mounted) {
        setState(() {
          _normalizePaymentPlan();
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
        _snackBar('Voucher không hợp lệ'),
      );
      return;
    }

    final voucher = found.first;
    if (!_voucherAppliesToCurrentBooking(voucher)) {
      ScaffoldMessenger.of(context).showSnackBar(
        _snackBar('Voucher không áp dụng cho dịch vụ đã chọn'),
      );
      return;
    }

    setState(() {
      appliedVoucher = voucher;
      _normalizePaymentPlan();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      _snackBar('Áp dụng voucher thành công'),
    );
  }

  void _selectVoucher(Map<String, dynamic>? voucher) {
    setState(() {
      appliedVoucher = voucher;

      if (voucher == null) {
        voucherCodeController.clear();
      }

      _normalizePaymentPlan();
    });
  }

  Future<void> _confirmAndCreateBooking() async {
    if (isSubmitting) return;

    if (_isBookingBlocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _blockReason ??
                'Tài khoản của bạn đang bị hạn chế đặt lịch do vượt quá số lần no-show ${_currentNoShowCount}/$_noShowLimit.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_loadingBookingPolicy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đang kiểm tra chính sách đặt lịch...'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (paymentPlan == _deposit && !allowDeposit) {
      ScaffoldMessenger.of(context).showSnackBar(
        _snackBar(
            'Đặt cọc $storeDepositPercent% chỉ áp dụng cho đơn từ ${_formatMoney(storeDepositThreshold)}'),
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

      final bookingId = await _createBookingAndGetId(dio, model);

      if (paymentPlan != _payLater) {
        final amountToPay = amountToPayNow.round();

        if (amountToPay <= 0) {
          throw Exception('Không có số tiền cần thanh toán ngay');
        }

        _waitingForPayment = true;

        final paymentResp = await dio.post(
          'payments/vnpay/create',
          data: {
            "bookingId": bookingId,
            "amount": amountToPay,
            "orderInfo": "Thanh toan booking $bookingId",
            "paymentMethod": paymentMethod,
          },
        );

        final paymentData = paymentResp.data;
        if (_isFailureResponse(paymentData)) {
          _waitingForPayment = false;
          throw Exception(
            _extractErrorMessage(paymentData,
                fallback: 'Không tạo được thanh toán'),
          );
        }

        final paymentUrl =
            paymentData is Map ? paymentData['url']?.toString() : null;

        if (paymentUrl == null || paymentUrl.isEmpty) {
          _waitingForPayment = false;
          throw Exception('Không nhận được URL thanh toán');
        }

        await _openPaymentUrl(paymentUrl);

        return;
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        _snackBar('Đặt lịch thành công'),
      );

      Navigator.popUntil(context, (route) => route.isFirst);
    } on DioException catch (e) {
      _waitingForPayment = false;
      final message = e.response?.data is Map
          ? _extractErrorMessage(e.response?.data, fallback: e.message ?? 'Lỗi')
          : (e.message ?? 'Đã xảy ra lỗi');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          _snackBar('Lỗi: $message'),
        );
      }
    } catch (e) {
      _waitingForPayment = false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          _snackBar('Lỗi: $e'),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  Future<bool> _confirmLeave() async {
    if (isSubmitting) return false;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        surfaceTintColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: Text(
          'Hủy đặt lịch?',
          style: AppTextStyles.sectionTitle,
        ),
        content: Text(
          'Bạn đang ở trang xác nhận booking. Rời trang sẽ hủy thao tác hiện tại.',
          style: AppTextStyles.bodyMuted,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              'Ở lại',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Rời đi',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  Future<void> _tryLeavePage() async {
    final ok = await _confirmLeave();
    if (ok && mounted) {
      Navigator.pop(context);
    }
  }

  void _handleDeepLink() async {
    _appLinks = AppLinks();

    final uri = await _appLinks.getInitialAppLink();
    if (uri != null) {
      _handleUri(uri);
    }

    _sub = _appLinks.uriLinkStream.listen((uri) {
      _handleUri(uri);
    });
  }

  void _handleUri(Uri uri) {
    if (!_waitingForPayment || _handledPayment) return;

    if (uri.scheme == 'myapp' && uri.host == 'payment-result') {
      _handledPayment = true;
      _waitingForPayment = false;

      final status = uri.queryParameters['status'];

      if (status == 'success') {
        _onPaymentSuccess();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            _snackBar('Thanh toán thất bại'),
          );
        }
      }
    }
  }

  void _onPaymentSuccess() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      _snackBar('Đã thanh toán & đặt lịch thành công'),
    );

    context.go('/booking');
  }

  void _showVoucherBottomSheet() {
    Map<String, dynamic>? tempSelectedVoucher = appliedVoucher;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 24),
                        const Text('Chọn Mã Giảm Giá',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: TextField(
                              controller: voucherCodeController,
                              decoration: InputDecoration(
                                hintText: 'Nhập mã giảm giá...',
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () {
                              _applyVoucherByCode();
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                            ),
                            child: const Text('Áp dụng',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  Expanded(
                    child: vouchers.isEmpty
                        ? const Center(
                            child: Text('Hiện chưa có mã giảm giá nào.',
                                style: TextStyle(color: Colors.grey)))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            itemCount: vouchers.length,
                            itemBuilder: (context, index) {
                              final v = vouchers[index];
                              final canApply =
                                  _voucherAppliesToCurrentBooking(v);
                              final isSelected = tempSelectedVoucher != null &&
                                  tempSelectedVoucher!['code'] == v['code'];

                              final code = v['code'] ?? '';
                              final val =
                                  (v['discountValue'] as num).toDouble();
                              final isPercent = v['discountType'] == 0;
                              final maxDiscount = v['maxDiscount'] != null
                                  ? (v['maxDiscount'] as num).toDouble()
                                  : null;
                              final minOrder = v['minOrderValue'] != null
                                  ? (v['minOrderValue'] as num).toDouble()
                                  : 0;

                       String expiryDate = 'Đang cập nhật';

                                if (v['endDate'] != null) {
                                  try {
                                    String rawDate = v['endDate'].toString();
                                    DateTime parsedDate;

                                    bool hasTimezone =
                                        rawDate.endsWith('Z') ||
                                        rawDate.contains('+07:00') ||
                                        rawDate.contains('+00:00');

                                    if (hasTimezone) {
                                      parsedDate = DateTime.parse(rawDate).toLocal();
                                    } else {
                                      parsedDate =
                                          DateTime.parse(rawDate).add(const Duration(hours: 7));
                                    }

                                    expiryDate =
                                        DateFormat('HH:mm dd/MM/yyyy').format(parsedDate);
                                  } catch (e) {
                                    expiryDate = 'Lỗi ngày tháng';
                                  }
                                }

                              String titleStr = isPercent
                                  ? 'Giảm ${val.toInt()}%'
                                  : 'Giảm ${val.toInt()}đ';
                              if (isPercent &&
                                  maxDiscount != null &&
                                  maxDiscount > 0) {
                                titleStr +=
                                    ' Giảm tối đa ${maxDiscount.toInt()}đ';
                              }

                              final potentialDiscount =
                                  _calculatePotentialDiscount(v);

                              return GestureDetector(
                                onTap: canApply
                                    ? () {
                                        setModalState(() {
                                          if (isSelected) {
                                            tempSelectedVoucher = null;
                                            voucherCodeController.clear();
                                          } else {
                                            tempSelectedVoucher = v;
                                            voucherCodeController.text = code;
                                          }
                                        });
                                      }
                                    : null,
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: isSelected
                                            ? AppColors.primary
                                            : Colors.transparent,
                                        width: isSelected ? 1.5 : 0),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2))
                                    ],
                                  ),
                                  child: IntrinsicHeight(
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 100,
                                          decoration: BoxDecoration(
                                            color: canApply
                                                ? AppColors.primary
                                                : Colors.grey.shade400,
                                            borderRadius:
                                                const BorderRadius.only(
                                                    topLeft: Radius.circular(7),
                                                    bottomLeft:
                                                        Radius.circular(7)),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Text('VOUCHER',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12)),
                                              const SizedBox(height: 4),
                                              Text(code,
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      fontSize: 14),
                                                  textAlign: TextAlign.center,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(12),
                                            child: Opacity(
                                              opacity: canApply ? 1.0 : 0.5,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(titleStr,
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14),
                                                      maxLines: 2,
                                                      overflow: TextOverflow
                                                          .ellipsis),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                      'Đơn tối thiểu ${minOrder.toInt()}đ',
                                                      style: TextStyle(
                                                          color: Colors
                                                              .grey.shade600,
                                                          fontSize: 12)),
                                                  const SizedBox(height: 4),
                                                  Text('HSD: $expiryDate',
                                                      style: TextStyle(
                                                          color: Colors
                                                              .grey.shade500,
                                                          fontSize: 11)),
                                                  if (canApply &&
                                                      potentialDiscount >
                                                          0) ...[
                                                    const SizedBox(height: 6),
                                                    Text(
                                                        'Tiết kiệm ${potentialDiscount.toInt()}đ',
                                                        style: const TextStyle(
                                                            color: Colors.red,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600)),
                                                  ]
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 12),
                                          child: Icon(
                                            isSelected
                                                ? Icons.check_circle
                                                : Icons.radio_button_unchecked,
                                            color: isSelected
                                                ? AppColors.primary
                                                : Colors.grey.shade300,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            offset: const Offset(0, -4),
                            blurRadius: 8)
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectVoucher(tempSelectedVoucher);
                          _normalizePaymentPlan();
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('ĐỒNG Ý',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('dd/MM/yyyy').format(widget.appointmentDate);
    final discount = computeDiscount();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _tryLeavePage();
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppDecorations.pageGradient,
          ),
          child: SafeArea(
            child: loading
                ? _buildLoading()
                : error != null
                    ? _buildErrorView()
                    : Column(
                        children: [
                          _buildTopBar(),
                          Expanded(
                            child: ListView(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              children: [
                                _sectionCard(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        storeData?['name'] ?? '',
                                        style:
                                            AppTextStyles.sectionTitle.copyWith(
                                          fontSize: 18,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        storeData?['address'] ?? '',
                                        style: AppTextStyles.bodyMuted,
                                      ),
                                      const SizedBox(height: 14),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _miniStat(
                                              label: 'Ngày hẹn',
                                              value: dateLabel,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: _miniStat(
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
                                            child: _miniStat(
                                              label: 'Tổng thời gian',
                                              value: '$totalDuration phút',
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: _miniStat(
                                              label: 'Nhân viên',
                                              value: widget.staffId == null
                                                  ? 'Bất kỳ'
                                                  : (widget.staffName ??
                                                      'Đã chọn'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _sectionHeader('Dịch vụ'),
                                const SizedBox(height: 10),
                                ...selectedServiceDetails.map((s) {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface
                                          .withValues(alpha: 0.96),
                                      borderRadius: BorderRadius.circular(18),
                                      border:
                                          Border.all(color: AppColors.border),
                                      boxShadow: AppDecorations.softShadow,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                s['name'].toString(),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style:
                                                    AppTextStyles.body.copyWith(
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${(s['durationMinutes'] as num).toInt()} phút',
                                                style: AppTextStyles.bodyMuted,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          _formatMoney(
                                            (s['price'] as num).toDouble(),
                                          ),
                                          style: AppTextStyles.body.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                                const SizedBox(height: 8),
                                _sectionHeader('Voucher'),
                                const SizedBox(height: 10),
                                _sectionCard(
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: _showVoucherBottomSheet,
                                      borderRadius: BorderRadius.circular(8),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(
                                                    Icons.local_offer_outlined,
                                                    color: AppColors.primary),
                                                const SizedBox(width: 8),
                                                const Text(
                                                  'Mã giảm giá',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  appliedVoucher != null
                                                      ? 'Đã chọn 1 mã'
                                                      : 'Chọn hoặc nhập mã',
                                                  style: TextStyle(
                                                    color: appliedVoucher !=
                                                            null
                                                        ? AppColors.primary
                                                        : Colors.grey.shade600,
                                                    fontWeight:
                                                        appliedVoucher != null
                                                            ? FontWeight.w600
                                                            : FontWeight.normal,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                const Icon(Icons.chevron_right,
                                                    color: Colors.grey),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _sectionHeader('Thanh toán'),
                                const SizedBox(height: 10),
                                _sectionCard(
                                  child: Column(
                                    children: [
                                      if (allowCashOnDelivery) ...[
                                        _paymentOptionCard(
                                          selected: paymentPlan == _payLater,
                                          enabled: true,
                                          onTap: () {
                                            setState(() {
                                              paymentPlan = _payLater;
                                            });
                                          },
                                          title: 'Thanh toán sau',
                                          subtitle: 'COD tại cửa hàng',
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                      _paymentOptionCard(
                                        selected: paymentPlan == _payFull,
                                        enabled: true,
                                        onTap: () {
                                          setState(() {
                                            paymentPlan = _payFull;
                                          });
                                        },
                                        title: 'Thanh toán toàn bộ',
                                        subtitle:
                                            'VNPay • ${_formatMoney(finalTotal)}',
                                      ),
                                      const SizedBox(height: 8),
                                      _paymentOptionCard(
                                        selected: paymentPlan == _deposit,
                                        enabled: allowDeposit,
                                        onTap: allowDeposit
                                            ? () {
                                                setState(() {
                                                  paymentPlan = _deposit;
                                                });
                                              }
                                            : null,
                                        title: 'Đặt cọc $storeDepositPercent%',
                                        subtitle: allowDeposit
                                            ? 'VNPay • ${_formatMoney(finalTotal * (storeDepositPercent / 100))}'
                                            : 'Chỉ áp dụng cho đơn từ ${_formatMoney(storeDepositThreshold)}',
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _sectionHeader('Ghi chú'),
                                const SizedBox(height: 10),
                                _sectionCard(
                                  child: TextField(
                                    style: AppTextStyles.body,
                                    decoration: _inputDecoration(
                                      label: 'Ghi chú cho cửa hàng',
                                      alignLabelWithHint: true,
                                    ),
                                    maxLines: 3,
                                    onChanged: (v) => customerNote = v,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _sectionHeader('Tổng kết'),
                                const SizedBox(height: 10),
                              _sectionCard(
                                child: Column(
                                  children: [
                                    if (discount > 0) ...[
                                      _summaryRow(
                                        label: 'Tổng giá gốc',
                                        value: _formatMoney(subtotal),
                                      ),
                                      const SizedBox(height: 10),
                                      _summaryRow(
                                        label: 'Giảm giá',
                                        value: '- ${_formatMoney(discount)}',
                                        valueColor: AppColors.danger,
                                      ),
                                      const SizedBox(height: 10),
                                      _summaryRow(
                                        label: 'Tổng sau giảm',
                                        value: _formatMoney(finalTotal),
                                      ),
                                    ]
                                    else ...[
                                      _summaryRow(
                                        label: 'Tổng cộng',
                                        value: _formatMoney(subtotal),
                                      ),
                                    ],

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
              color: AppColors.surface.withValues(alpha: 0.97),
              border: const Border(
                top: BorderSide(color: AppColors.border),
              ),
              boxShadow: AppDecorations.topBarShadow,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _summaryTile(
                        label: 'Thanh toán ngay',
                        value: _formatMoney(amountToPayNow),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _summaryTile(
                        label: 'Hình thức',
                        value: paymentPlan == _payLater ? 'COD' : 'VNPay',
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
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          AppColors.primary.withValues(alpha: 0.35),
                      disabledForegroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
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
                            'Xác nhận đặt lịch',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppDecorations.cardShadow,
          border: Border.all(color: AppColors.borderSoft),
        ),
        child: const CircularProgressIndicator(
          strokeWidth: 2.6,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Column(
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
                  style: AppTextStyles.pageTitle,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppDecorations.cardShadow,
                ),
                child: Text(
                  error!,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.error.copyWith(
                    color: AppColors.danger,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    return Padding(
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
              style: AppTextStyles.pageTitle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: AppTextStyles.sectionTitle,
      ),
    );
  }

  Widget _sectionCard({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: AppDecorations.cardShadow,
      ),
      child: child,
    );
  }

  Widget _miniStat({
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 13.5,
            ),
          ),
        ],
      ),
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
            style: AppTextStyles.bodyMuted.copyWith(
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w800,
            color: valueColor ?? AppColors.textPrimary,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 13.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentOptionCard({
    required bool selected,
    required bool enabled,
    required VoidCallback? onTap,
    required String title,
    required String subtitle,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: enabled ? onTap : null,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.08)
                : AppColors.surfaceSoft,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.borderSoft,
              width: selected ? 1.2 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 14.5,
                        color: enabled
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodyMuted.copyWith(
                        height: 1.35,
                        color: enabled
                            ? AppColors.textSecondary
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? AppColors.primary : Colors.transparent,
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.border,
                    width: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _backButton(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: _tryLeavePage,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: AppDecorations.softShadow,
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 16,
          color: AppColors.primary,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    bool alignLabelWithHint = false,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppTextStyles.bodyMuted,
      alignLabelWithHint: alignLabelWithHint,
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    );
  }

  SnackBar _snackBar(String message) {
    return SnackBar(
      content: Text(message),
      backgroundColor: AppColors.textPrimary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }
}
