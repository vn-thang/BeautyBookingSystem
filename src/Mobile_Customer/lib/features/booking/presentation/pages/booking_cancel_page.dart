import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:mobile_customer/core/theme/app_colors.dart';
import 'package:mobile_customer/core/theme/app_decorations.dart';
import 'package:mobile_customer/core/theme/app_text_styles.dart';
import 'package:mobile_customer/injection/service_locator.dart' as di;

import '../../data/models/booking_models.dart';

class BookingCancelPage extends StatefulWidget {
  final BookingItem booking;

  const BookingCancelPage({
    super.key,
    required this.booking,
  });

  @override
  State<BookingCancelPage> createState() => _BookingCancelPageState();
}

class _BookingCancelPageState extends State<BookingCancelPage> {
  static const int _fallbackCancelBeforeHours = 3;

  String? _selectedReason;
  final TextEditingController _noteController = TextEditingController();

  int _cancelBeforeHours = _fallbackCancelBeforeHours;

  @override
  void initState() {
    super.initState();
    _loadCancelBeforeHours();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadCancelBeforeHours() async {
    try {
      final dio = di.sl<Dio>();
      final resp = await dio.get('public/system-configs/booking-policies');

      dynamic rawValue;

      final data = resp.data;
      if (data is Map<String, dynamic>) {
        final payload = data['data'];

        if (payload is Map<String, dynamic>) {
          rawValue = payload['value'] ??
              payload['configValue'] ??
              payload['settingValue'] ??
              payload['content'];
        } else {
          rawValue = data['value'] ??
              data['configValue'] ??
              data['settingValue'] ??
              data['content'];
        }
      }

      final parsed = int.tryParse('$rawValue');
      if (parsed != null && parsed > 0 && mounted) {
        setState(() {
          _cancelBeforeHours = parsed;
        });
      }
    } catch (_) {
      // Giữ fallback = 3 nếu API không truy cập được hoặc không có quyền.
    }
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

  double get _successfulPaidAmount {
    return widget.booking.payments
        .where((p) => p.status == 1)
        .fold(0.0, (sum, p) => sum + p.amount);
  }

  bool get _hasPaidDeposit => widget.booking.depositPaidAmount > 0;

  bool get _hasPaidFull =>
      widget.booking.finalPrice > 0 && widget.booking.remainingAmount <= 0;

  bool get _hasAnyPayment => _successfulPaidAmount > 0;

  bool get _warnLoseDeposit {
    final dt = _bookingDateTime(widget.booking);
    if (!_hasPaidDeposit || dt == null) return false;

    final now = DateTime.now();
    return dt.isBefore(now.add(Duration(hours: _cancelBeforeHours)));
  }

  String _formatVnd(num value) {
    final formatted = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    ).format(value.abs()).replaceAll('\u00A0', ' ');
    return value < 0 ? '-$formatted' : formatted;
  }

  String _buildReason() {
    final reason = _selectedReason?.trim() ?? '';
    final note = _noteController.text.trim();

    final combined = <String>[
      if (reason.isNotEmpty) reason,
      if (note.isNotEmpty) note,
    ].join(' - ');

    return combined.isEmpty ? 'Khách yêu cầu hủy booking' : combined;
  }

  Future<void> _confirmCancel() async {
    final reason = _buildReason();

    final message = !_hasAnyPayment
        ? 'Đơn này chưa thanh toán. Bạn có chắc muốn hủy booking này không?'
        : _hasPaidFull
            ? _warnLoseDeposit
                ? 'Đơn này đã thanh toán đầy đủ và đã quá thời gian hủy miễn phí (${_cancelBeforeHours} giờ). Khi hủy, việc hoàn tiền sẽ phụ thuộc vào chính sách của cửa hàng. Bạn có chắc muốn hủy không?'
                : 'Đơn này đã thanh toán đầy đủ. Khi hủy, việc hoàn tiền sẽ phụ thuộc vào chính sách của cửa hàng. Bạn có chắc muốn hủy không?'
            : _warnLoseDeposit
                ? 'Đơn này đã có cọc và đã quá thời gian hủy miễn phí (${_cancelBeforeHours} giờ). Nếu tiếp tục, bạn có thể mất tiền cọc. Bạn có chắc muốn hủy không?'
                : 'Đơn này đã có cọc nhưng vẫn trong thời gian hủy miễn phí (${_cancelBeforeHours} giờ). Bạn có chắc muốn hủy không?';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xác nhận hủy booking'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Không'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Hủy booking',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    if (!mounted) return;
    Navigator.pop(context, reason);
  }

  @override
  Widget build(BuildContext context) {
    final presetReasons = <String>[
      'Bận việc đột xuất',
      'Không sắp xếp được thời gian',
      'Sức khỏe không đảm bảo',
      'Đặt nhầm lịch',
      'Lý do khác',
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _summaryCard(),
                    const SizedBox(height: 12),
                    _warningCard(),
                    const SizedBox(height: 12),
                    _sectionTitle('Chọn lý do hủy'),
                    const SizedBox(height: 8),
                    _sectionCard(
                      child: Column(
                        children: presetReasons.map((reason) {
                          return RadioListTile<String>(
                            contentPadding: EdgeInsets.zero,
                            value: reason,
                            groupValue: _selectedReason,
                            onChanged: (value) {
                              setState(() => _selectedReason = value);
                            },
                            title: Text(
                              reason,
                              style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _sectionTitle('Ghi chú thêm'),
                    const SizedBox(height: 8),
                    _sectionCard(
                      child: TextField(
                        controller: _noteController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Nhập lý do chi tiết nếu cần...',
                          hintStyle: AppTextStyles.bodyMuted,
                          filled: true,
                          fillColor: AppColors.surface,
                          contentPadding: const EdgeInsets.all(16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide:
                                const BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide:
                                const BorderSide(color: AppColors.border),
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
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            _bottomAction(),
          ],
        ),
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
                  'Hủy booking',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.pageTitle,
                ),
                SizedBox(height: 4),
                Text(
                  'Xác nhận lý do hủy lịch hẹn',
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

  Widget _summaryCard() {
    final statusLabel = switch (widget.booking.status) {
      0 => 'Chờ xác nhận',
      1 => 'Đã đặt cọc',
      2 => 'Đã xác nhận',
      3 => 'Hoàn thành',
      4 => 'Đã hủy',
      _ => 'Không rõ',
    };

    final statusColor = switch (widget.booking.status) {
      0 => AppColors.warning,
      1 => AppColors.success,
      2 => const Color.fromARGB(255, 42, 187, 83),
      3 => AppColors.secondary,
      4 => AppColors.danger,
      _ => AppColors.textSecondary,
    };

DateTime? exactDateTime;

if (widget.booking.services.isNotEmpty) {
  final s = widget.booking.services.first;
  final parts = s.startTime.split(':');
  
  if (parts.length >= 2) {
    exactDateTime = DateTime(
      s.appointmentDate.year,
      s.appointmentDate.month,
      s.appointmentDate.day,
      int.tryParse(parts[0]) ?? 0,
      int.tryParse(parts[1]) ?? 0,
    );
  } else {
    exactDateTime = s.appointmentDate;
  }
} else {
  exactDateTime = widget.booking.createdAt;
}

final dateLabel = exactDateTime != null
    ? DateFormat('HH:mm - dd/MM/yyyy').format(exactDateTime)
    : '-';

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
                  widget.booking.storeName?.trim().isNotEmpty == true
                      ? widget.booking.storeName!
                      : 'Booking #${widget.booking.id}',
                  style: AppTextStyles.sectionTitle.copyWith(fontSize: 17),
                ),
              ),
              _StatusChip(label: statusLabel, color: statusColor),
            ],
          ),
          const SizedBox(height: 10),
        _simpleInfoRow('Mã booking', '#${widget.booking.id}'),
        
        const SizedBox(height: 6),
        _simpleInfoRow('Lịch hẹn', dateLabel),
        
        if (widget.booking.depositAmount > 0) ...[
          const SizedBox(height: 6),
          _simpleInfoRow('Cọc yêu cầu', _formatVnd(widget.booking.depositAmount)),
        ],
        
        if (widget.booking.depositPaidAmount > 0) ...[
          const SizedBox(height: 6),
          _simpleInfoRow('Đã cọc', _formatVnd(widget.booking.depositPaidAmount)),
        ],
        
        
          const SizedBox(height: 6),
          _simpleInfoRow('Đã thanh toán', _formatVnd(_successfulPaidAmount)),
       
      ],
    ),
    );
  }

  Widget _warningCard() {
    if (!_hasAnyPayment) {
      return _infoCard(
        icon: Icons.info_outline_rounded,
        color: AppColors.primary,
        text: 'Đơn này chưa thanh toán, bạn có thể hủy bình thường.',
      );
    }

    if (_hasPaidFull) {
      return _infoCard(
        icon: Icons.warning_amber_rounded,
        color: AppColors.warning,
        text:
            'Đơn này đã thanh toán đầy đủ. Khi hủy, việc hoàn tiền sẽ phụ thuộc vào chính sách của cửa hàng.',
      );
    }

    if (_warnLoseDeposit) {
      return _infoCard(
        icon: Icons.warning_amber_rounded,
        color: AppColors.danger,
        text:
            'Đơn này đã có cọc và đã quá thời gian hủy miễn phí (${_cancelBeforeHours} giờ). Nếu tiếp tục, bạn có thể mất tiền cọc.',
        isBold: true,
      );
    }

    return _infoCard(
      icon: Icons.info_outline_rounded,
      color: AppColors.warning,
      text:
          'Đơn này đã có cọc nhưng vẫn nằm trong thời gian hủy miễn phí (${_cancelBeforeHours} giờ).',
      isBold: true,
    );
  }

  Widget _infoCard({
    required IconData icon,
    required Color color,
    required String text,
    bool isBold = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: AppDecorations.softShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body.copyWith(
                color: isBold ? color : AppColors.textSecondary,
                height: 1.4,
                fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
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
          width: 100,
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

  Widget _bottomAction() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _confirmCancel,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: AppColors.surface,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Xác nhận hủy',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
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
