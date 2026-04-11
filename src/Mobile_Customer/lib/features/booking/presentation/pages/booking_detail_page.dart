import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

import 'package:mobile_customer/core/theme/app_colors.dart';
import 'package:mobile_customer/core/theme/app_decorations.dart';
import 'package:mobile_customer/core/theme/app_text_styles.dart';
import 'package:mobile_customer/injection/service_locator.dart' as di;

import '../../../review/domain/entities/review_entity.dart';
import '../../../review/presentation/bloc/review_bloc.dart';
import '../../../review/presentation/bloc/review_event.dart';
import '../../../review/presentation/bloc/review_state.dart';
import '../../data/models/booking_models.dart';

class BookingDetailPage extends StatefulWidget {
  final int bookingId;
  final BookingItem? initialBooking;

  const BookingDetailPage({
    super.key,
    required this.bookingId,
    this.initialBooking,
  });

  @override
  State<BookingDetailPage> createState() => _BookingDetailPageState();
}

class _BookingDetailPageState extends State<BookingDetailPage>
    with WidgetsBindingObserver {
  BookingItem? _item;
  bool _loading = true;
  String? _error;
  late final ReviewBloc _reviewBloc;
  bool _processingPay = false;
  bool _processingCancel = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _item = widget.initialBooking;
    _reviewBloc = di.sl<ReviewBloc>()..add(LoadMyReviews());
    _loadDetail();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _reviewBloc.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadDetail();
    }
  }

  String _formatVnd(num value) {
    final formatted = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    ).format(value.abs()).replaceAll('\u00A0', ' ');

    return value < 0 ? '-$formatted' : formatted;
  }

  DateTime? _bookingDateTime(BookingItem item) {
    if (item.services.isNotEmpty) {
      final s = item.services.first;
      final parts = s.startTime.split(':');
      if (parts.length >= 2) {
        return DateTime(
          s.appointmentDate.year,
          s.appointmentDate.month,
          s.appointmentDate.day,
          int.tryParse(parts[0]) ?? 0,
          int.tryParse(parts[1]) ?? 0,
        );
      }
      return s.appointmentDate;
    }

    return item.createdAt;
  }

  String _appointmentRangeText(BookingItem item) {
    if (item.services.isEmpty) return '-';

    final services = [...item.services]..sort((a, b) {
        final dateCompare = a.appointmentDate.compareTo(b.appointmentDate);
        if (dateCompare != 0) return dateCompare;
        return a.startTime.compareTo(b.startTime);
      });

    final first = services.first;

    String normalizeTime(String value) {
      final parts = value.split(':');
      if (parts.length >= 2) {
        return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
      }
      return value;
    }

    final firstDate = DateFormat('dd/MM/yyyy').format(first.appointmentDate);
    final startText = normalizeTime(first.startTime);

    return '$firstDate • $startText';
  }

  bool _canCancel(BookingItem item) {
    final dt = _bookingDateTime(item);
    if (dt == null) return false;

    final now = DateTime.now();
    return dt.difference(now).inHours >= 24;
  }

  Future<void> _loadDetail() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final dio = di.sl<Dio>();
      final resp = await dio.get('bookings/${widget.bookingId}');

      final data = resp.data;

      Map<String, dynamic>? bookingJson;

      if (data is Map<String, dynamic>) {
        // Trường hợp API trả trực tiếp DTO
        if (data.containsKey('id')) {
          bookingJson = data;
        }
        // Trường hợp API trả kiểu { success: true, data: {...} }
        else if (data['data'] is Map<String, dynamic>) {
          bookingJson = Map<String, dynamic>.from(data['data']);
        }
      }

      if (bookingJson == null) {
        throw Exception('Invalid booking response format');
      }

      if (!mounted) return;
      setState(() {
        _item = BookingItem.fromJson(bookingJson!);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _item = widget.initialBooking;
        _loading = false;
        _error = widget.initialBooking == null ? e.toString() : null;
      });
    }
  }

  Future<void> _handlePayNow(BookingItem item) async {
    final amount = item.remainingAmount.round();
    if (amount <= 0 || _processingPay) return;

    setState(() => _processingPay = true);

    try {
      final dio = di.sl<Dio>();

      final resp = await dio.post(
        'payments/vnpay/create',
        data: {
          'bookingId': item.id,
          'amount': amount,
          'orderInfo': 'Thanh toán booking #${item.id}',
          'paymentMethod': 1, // đổi theo enum backend của bạn
        },
      );

      final url = resp.data['url'] as String?;
      if (url == null || url.isEmpty) {
        throw Exception('Không nhận được URL thanh toán');
      }

      final ok = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );

      if (!ok) {
        throw Exception('Không mở được cổng thanh toán');
      }

      // Khi người dùng quay lại app, didChangeAppLifecycleState sẽ tự reload booking
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Thanh toán thất bại: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _processingPay = false);
      }
    }
  }

  Future<void> _openReviewSheet(BookingItem item) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return BlocProvider.value(
          value: _reviewBloc,
          child: ReviewFormSheet(booking: item),
        );
      },
    );

    if (!mounted) return;

    if (result == true) {
      _reviewBloc.add(LoadMyReviews());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Đánh giá thành công'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.success,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      setState(() {});
    }
  }

  Future<void> _openViewReviewSheet(ReviewEntity review) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return ReviewDetailSheet(review: review);
      },
    );
  }

  // Future<void> _requestCancel(BookingItem item) async {
  //   if (_processingCancel) return;

  //   final canCancel = _canCancel(item);
  //   if (!canCancel) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Chỉ được hủy trước 24 giờ của lịch hẹn'),
  //         behavior: SnackBarBehavior.floating,
  //       ),
  //     );
  //     return;
  //   }

  //   final confirmed = await showDialog<bool>(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: const Text('Yêu cầu hủy booking'),
  //         content: const Text('Bạn có chắc muốn hủy booking này không?'),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(context, false),
  //             child: const Text('Không'),
  //           ),
  //           ElevatedButton(
  //             onPressed: () => Navigator.pop(context, true),
  //             child: const Text('Có, hủy booking'),
  //           ),
  //         ],
  //       );
  //     },
  //   );

  //   if (confirmed != true) return;

  //   setState(() => _processingCancel = true);

  //   try {
  //     final dio = di.sl<Dio>();
  //     await dio.post(
  //       'bookings/${item.id}/cancel',
  //       data: {
  //         'reason': 'Khách yêu cầu hủy',
  //       },
  //     );

  //     await _loadDetail();

  //     if (!mounted) return;
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Đã gửi yêu cầu hủy booking'),
  //         behavior: SnackBarBehavior.floating,
  //         backgroundColor: AppColors.success,
  //       ),
  //     );
  //   } catch (e) {
  //     if (!mounted) return;
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Hủy booking thất bại: $e'),
  //         behavior: SnackBarBehavior.floating,
  //         backgroundColor: AppColors.danger,
  //       ),
  //     );
  //   } finally {
  //     if (mounted) {
  //       setState(() => _processingCancel = false);
  //     }
  //   }
  // }

  Future<void> _requestCancel(BookingItem item) async {
    if (_processingCancel) return;

    // 1. Bỏ check 24h đi. Chỉ cần check cơ bản tránh user bấm nhầm khi đơn đã hủy/hoàn thành
    if (item.status == 'Cancelled' || item.status == 'Completed') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lịch hẹn này đã kết thúc hoặc bị hủy, không thể thao tác thêm.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Yêu cầu hủy booking'),
          content: const Text('Bạn có chắc muốn hủy booking này không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Không'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red), // Nút hủy nên cho màu đỏ
              child: const Text('Có, hủy booking', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() => _processingCancel = true);

    try {
      final dio = di.sl<Dio>();
      await dio.post(
        'bookings/${item.id}/cancel',
        data: {
          'reason': 'Khách yêu cầu hủy',
        },
      );

      await _loadDetail();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã hủy booking thành công'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.success,
        ),
      );
      
    // 2. BẮT LỖI TỪ BACKEND BẰNG DioException
    } on DioException catch (e) {
      if (!mounted) return;
      
      // Trích xuất câu thông báo lỗi động từ Backend C# gửi về
      // (Ví dụ: "Quy định cửa hàng: Chỉ được hủy trước 3 giờ...")
      String errorMessage = 'Hủy booking thất bại';
      
      if (e.response != null && e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map<String, dynamic>) {
           // Đọc field 'message' hoặc 'title' tùy thuộc vào cách Middleware C# của bạn cấu hình trả về
           errorMessage = data['message'] ?? data['title'] ?? data['detail'] ?? errorMessage;
        } else {
           errorMessage = data.toString();
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage), // Hiển thị nguyên văn lời cảnh báo của Backend
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.danger,
          duration: const Duration(seconds: 4), // Cho hiển thị lâu hơn chút để khách kịp đọc
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã có lỗi xảy ra: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _processingCancel = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _reviewBloc,
      child: BlocBuilder<ReviewBloc, ReviewState>(
        builder: (context, reviewState) {
          final item = _item;
          final reviewedReviews = reviewState is ReviewLoaded
              ? {for (final r in reviewState.reviews) r.bookingId: r}
              : <int, ReviewEntity>{};

          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Column(
                children: [
                  _topBar(),
                  Expanded(
                    child: _loading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          )
                        : _error != null
                            ? _buildError()
                            : item == null
                                ? _buildError(
                                    customMessage: 'Không có dữ liệu booking.')
                                : RefreshIndicator(
                                    color: AppColors.primary,
                                    onRefresh: _loadDetail,
                                    child: ListView(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      padding: const EdgeInsets.fromLTRB(
                                          16, 8, 16, 20),
                                      children: [
                                        _headerCard(item),
                                        const SizedBox(height: 12),
                                        _sectionTitle('Lịch hẹn'),
                                        const SizedBox(height: 8),
                                        _sectionCard(
                                          child: _simpleInfoRow(
                                            'Thời gian',
                                            _appointmentRangeText(item),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        _sectionTitle('Dịch vụ'),
                                        const SizedBox(height: 8),
                                        _sectionCard(
                                          child: item.services.isEmpty
                                              ? const Text(
                                                  'Không có dịch vụ.',
                                                  style:
                                                      AppTextStyles.bodyMuted,
                                                )
                                              : Column(
                                                  children:
                                                      item.services.map((s) {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 12),
                                                      child: _serviceTile(s),
                                                    );
                                                  }).toList(),
                                                ),
                                        ),
                                        const SizedBox(height: 12),
                                        _sectionTitle('Thanh toán'),
                                        const SizedBox(height: 8),
                                        _sectionCard(
                                          child: Column(
                                            children: [
                                              _priceLine(
                                                  'Tổng giá', item.totalPrice),
                                              _priceLine('Giảm giá',
                                                  -item.discountAmount),
                                              const Divider(height: 20),
                                              _priceLine('Tổng sau giảm',
                                                  item.finalPrice,
                                                  bold: true),
                                              _priceLine('Đã cọc',
                                                  item.depositPaidAmount),
                                              _priceLine('Đã thanh toán',
                                                  item.paidAmount),
                                              const Divider(height: 20),
                                              _priceLine(
                                                'Còn lại',
                                                item.remainingAmount,
                                                bold: true,
                                                highlight: true,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        _sectionTitle('Giao dịch'),
                                        const SizedBox(height: 8),
                                        _sectionCard(
                                          child: item.payments.isEmpty
                                              ? const Text(
                                                  'Chưa có giao dịch.',
                                                  style:
                                                      AppTextStyles.bodyMuted,
                                                )
                                              : Column(
                                                  children:
                                                      item.payments.map((p) {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 12),
                                                      child: _paymentTile(p),
                                                    );
                                                  }).toList(),
                                                ),
                                        ),
                                        if (_shouldShowPayButton(item)) ...[
                                          const SizedBox(height: 14),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              onPressed: () =>
                                                  _handlePayNow(item),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    AppColors.primary,
                                                foregroundColor:
                                                    AppColors.surface,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 14),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                elevation: 0,
                                              ),
                                              child: Text(
                                                item.depositPaidAmount > 0
                                                    ? 'Thanh toán nốt ${_formatVnd(item.remainingAmount)}'
                                                    : 'Thanh toán ngay ${_formatVnd(item.remainingAmount)}',
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.w700),
                                              ),
                                            ),
                                          ),
                                        ],
                                        if ((item.status == 0 ||
                                                item.status == 1) &&
                                            _canCancel(item)) ...[
                                          const SizedBox(height: 12),
                                          SizedBox(
                                            width: double.infinity,
                                            child: OutlinedButton(
                                              onPressed: _processingCancel
                                                  ? null
                                                  : () => _requestCancel(item),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor:
                                                    AppColors.danger,
                                                side: const BorderSide(
                                                    color: AppColors.danger),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 14),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                              ),
                                              child: Text(
                                                _processingCancel
                                                    ? 'Đang xử lý...'
                                                    : 'Yêu cầu hủy booking',
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.w700),
                                              ),
                                            ),
                                          ),
                                        ],
                                        if (item.status == 2 &&
                                            !reviewedReviews
                                                .containsKey(item.id)) ...[
                                          const SizedBox(height: 14),
                                          SizedBox(
                                            width: double.infinity,
                                            child: OutlinedButton(
                                              onPressed: () =>
                                                  _openReviewSheet(item),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor:
                                                    AppColors.primary,
                                                side: const BorderSide(
                                                    color: AppColors.primary),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 14),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                              ),
                                              child: const Text(
                                                'Đánh giá',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.w700),
                                              ),
                                            ),
                                          ),
                                        ] else if (reviewedReviews
                                            .containsKey(item.id)) ...[
                                          const SizedBox(height: 14),
                                          SizedBox(
                                            width: double.infinity,
                                            child: OutlinedButton(
                                              onPressed: () =>
                                                  _openViewReviewSheet(
                                                      reviewedReviews[
                                                          item.id]!),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor:
                                                    AppColors.textPrimary,
                                                side: const BorderSide(
                                                    color: AppColors.border),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 14),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                              ),
                                              child: const Text(
                                                'Xem đánh giá',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.w700),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Row(
        children: [
          _backButton(),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chi tiết booking',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.pageTitle,
                ),
                SizedBox(height: 4),
                Text(
                  'Thông tin lịch hẹn và thanh toán',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMuted,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerCard(BookingItem item) {
    final statusInfo = _statusInfo(item.status);
    final dateLabel = item.services.isNotEmpty
        ? DateFormat('dd/MM/yyyy').format(item.services.first.appointmentDate)
        : item.createdAt != null
            ? DateFormat('dd/MM/yyyy').format(item.createdAt!)
            : '-';

    final serviceSummary = item.effectiveServiceSummary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: AppDecorations.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.storeName?.trim().isNotEmpty == true
                      ? item.storeName!
                      : 'Booking #${item.id}',
                  style: AppTextStyles.sectionTitle.copyWith(fontSize: 17),
                ),
              ),
              _StatusChip(label: statusInfo.label, color: statusInfo.color),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            serviceSummary,
            style: AppTextStyles.bodyMuted.copyWith(height: 1.35),
          ),
          const SizedBox(height: 10),
          _simpleInfoRow('Ngày đặt', dateLabel),
          const SizedBox(height: 6),
          _simpleInfoRow('Mã booking', '#${item.id}'),
        ],
      ),
    );
  }

  Widget _serviceTile(BookingServiceItem s) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.serviceName,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${DateFormat('dd/MM/yyyy').format(s.appointmentDate)} • ${s.startTime.substring(0, 5)}',
                style: AppTextStyles.bodyMuted,
              ),
              if ((s.staffName ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Nhân viên: ${s.staffName}',
                  style: AppTextStyles.bodyMuted,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          _formatVnd(s.price),
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _paymentTile(BookingPaymentItem p) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${p.methodText} • ${_formatVnd(p.amount)}',
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                p.statusText +
                    (p.paidAt != null
                        ? ' • ${DateFormat('dd/MM/yyyy HH:mm').format(p.paidAt!)}'
                        : ''),
                style: AppTextStyles.bodyMuted,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _StatusChip(label: p.statusText, color: AppColors.textSecondary),
      ],
    );
  }

  bool _shouldShowPayButton(BookingItem item) {
    if (item.status == 3) return false;
    return item.remainingAmount > 0;
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.sectionTitle.copyWith(fontSize: 15.5),
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: AppDecorations.softShadow,
      ),
      child: child,
    );
  }

  Widget _simpleInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 92,
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _priceLine(String label, double value,
      {bool bold = false, bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.body.copyWith(
                fontSize: 13.5,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                color: highlight ? AppColors.primary : AppColors.textMuted,
              ),
            ),
          ),
          Text(
            _formatVnd(value),
            style: AppTextStyles.body.copyWith(
              fontSize: 13.5,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
              color: highlight ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError({String? customMessage}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
            boxShadow: AppDecorations.cardShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 36,
                color: AppColors.primary,
              ),
              const SizedBox(height: 12),
              Text(
                'Không thể tải chi tiết booking',
                style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                customMessage ?? _error ?? 'Đã xảy ra lỗi không xác định.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMuted.copyWith(height: 1.45),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loadDetail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.surface,
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

  Widget _backButton() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: AppDecorations.topBarShadow,
      ),
      child: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 17,
          color: AppColors.primary,
        ),
      ),
    );
  }

  ({String label, Color color}) _statusInfo(int status) {
    switch (status) {
      case 0:
        return (label: 'Chờ xác nhận', color: AppColors.warning);
      case 1:
        return (label: 'Đã xác nhận', color: AppColors.success);
      case 2:
        return (label: 'Hoàn thành', color: AppColors.secondary);
      case 3:
        return (label: 'Đã hủy', color: AppColors.danger);
      default:
        return (label: 'Không rõ', color: AppColors.textSecondary);
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class ReviewFormSheet extends StatefulWidget {
  final BookingItem booking;

  const ReviewFormSheet({
    super.key,
    required this.booking,
  });

  @override
  State<ReviewFormSheet> createState() => _ReviewFormSheetState();
}

class _ReviewFormSheetState extends State<ReviewFormSheet> {
  int _rating = 5;
  final TextEditingController _commentController = TextEditingController();
  bool _isClosed = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReviewBloc, ReviewState>(
      listener: (context, state) {
        if (state is ReviewSuccess && !_isClosed) {
          _isClosed = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              Navigator.of(context).pop(true);
            }
          });
        }

        if (state is ReviewFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.danger,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        final submitting = state is ReviewSubmitting;

        return SafeArea(
          child: Container(
            margin: const EdgeInsets.only(top: 24),
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Đánh giá booking',
                    style: AppTextStyles.sectionTitle,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Booking #${widget.booking.id}',
                    style: AppTextStyles.bodyMuted,
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final star = index + 1;
                      return IconButton(
                        onPressed: submitting
                            ? null
                            : () => setState(() => _rating = star),
                        icon: Icon(
                          star <= _rating
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          size: 34,
                          color: AppColors.warning,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _commentController,
                    maxLines: 4,
                    enabled: !submitting,
                    decoration: InputDecoration(
                      hintText: 'Viết nhận xét của bạn...',
                      hintStyle: AppTextStyles.bodyMuted,
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: const EdgeInsets.all(16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1.4,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: submitting
                          ? null
                          : () {
                              context.read<ReviewBloc>().add(
                                    SubmitReview(
                                      bookingId: widget.booking.id,
                                      rating: _rating,
                                      comment: _commentController.text.trim(),
                                    ),
                                  );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.surface,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: submitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.surface,
                              ),
                            )
                          : const Text(
                              'Gửi đánh giá',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ReviewDetailSheet extends StatelessWidget {
  final ReviewEntity review;

  const ReviewDetailSheet({
    super.key,
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.only(top: 24),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Đánh giá của bạn',
                style: AppTextStyles.sectionTitle,
              ),
              const SizedBox(height: 8),
              Text(
                review.storeName.isNotEmpty
                    ? review.storeName
                    : 'Booking #${review.bookingId}',
                style: AppTextStyles.bodyMuted,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final star = index + 1;
                  return Icon(
                    star <= review.rating
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    size: 30,
                    color: AppColors.warning,
                  );
                }),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppDecorations.softShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Nhận xét', style: AppTextStyles.caption),
                    const SizedBox(height: 8),
                    Text(
                      (review.comment?.trim().isNotEmpty == true)
                          ? review.comment!
                          : 'Không có nhận xét.',
                      style: AppTextStyles.body
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    if (review.reply?.trim().isNotEmpty == true) ...[
                      const SizedBox(height: 14),
                      const Divider(height: 1),
                      const SizedBox(height: 14),
                      const Text('Phản hồi của shop',
                          style: AppTextStyles.caption),
                      const SizedBox(height: 8),
                      Text(
                        review.reply!,
                        style: AppTextStyles.body
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.surface,
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
            ],
          ),
        ),
      ),
    );
  }
}
