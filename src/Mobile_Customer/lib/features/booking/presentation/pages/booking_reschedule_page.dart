import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:mobile_customer/core/theme/app_colors.dart';
import 'package:mobile_customer/core/theme/app_decorations.dart';
import 'package:mobile_customer/core/theme/app_text_styles.dart';
import 'package:mobile_customer/injection/service_locator.dart' as di;

import '../../data/models/booking_models.dart';
import 'booking_reschedule_staff_page.dart';

class BookingReschedulePage extends StatefulWidget {
  final BookingItem booking;
  final int rescheduleBeforeHours;

  const BookingReschedulePage({
    super.key,
    required this.booking,
    required this.rescheduleBeforeHours,
  });

  @override
  State<BookingReschedulePage> createState() => _BookingReschedulePageState();
}

class _BookingReschedulePageState extends State<BookingReschedulePage> {
  DateTime? selectedDate;
  String? selectedSlot;

  final Map<String, bool> _slotAvailability = {};
  bool _checkingAvailability = false;
  bool _submitting = false;

  final TextEditingController _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
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

  DateTime _normalizeDate(DateTime d) => DateTime(d.year, d.month, d.day);

  String _formatDateLabel(DateTime date) {
    const weekdays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    final weekday =
        weekdays[date.weekday == DateTime.sunday ? 6 : date.weekday - 1];
    return '$weekday, ${DateFormat('dd/MM/yyyy').format(date)}';
  }

  String _slotKey(DateTime date, String slot) {
    final d = _normalizeDate(date);
    return '${d.year}-${d.month}-${d.day}_$slot';
  }

  List<int> _serviceIds() {
    return widget.booking.services.map((e) => e.serviceId).toList();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      firstDate: _normalizeDate(now),
      lastDate: _normalizeDate(now.add(const Duration(days: 60))),
      initialDate: selectedDate ?? _normalizeDate(now),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
            dialogBackgroundColor: AppColors.surface,
            datePickerTheme: DatePickerThemeData(
              backgroundColor: AppColors.surface,
              headerBackgroundColor: AppColors.surfaceSoft,
              headerForegroundColor: AppColors.textPrimary,
              dividerColor: AppColors.borderSoft,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              dayStyle: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              todayForegroundColor: const WidgetStatePropertyAll(
                AppColors.primary,
              ),
              todayBorder: const BorderSide(color: AppColors.primary),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      final normalized = _normalizeDate(picked);

      setState(() {
        selectedDate = normalized;
        selectedSlot = null;
        _slotAvailability.clear();
      });

      await _loadAvailabilityForDate(normalized);
    }
  }

  Future<void> _loadAvailabilityForDate(DateTime date) async {
    setState(() {
      _checkingAvailability = true;
    });

    try {
      final dio = di.sl<Dio>();
      final resp = await dio.post(
        'bookings/available-time-slots',
        data: {
          'storeId': widget.booking.storeId,
          'serviceIds': _serviceIds(),
          'date': DateFormat('yyyy-MM-dd').format(date),
          'excludeBookingId': widget.booking.id,
        },
      );

      final raw = resp.data;
      final List<dynamic> dataList = [];

      if (raw is Map<String, dynamic>) {
        final payload = raw['data'];
        if (payload is List) {
          dataList.addAll(payload);
        }
      } else if (raw is List) {
        dataList.addAll(raw);
      }

      final results = <String, bool>{};

      for (final item in dataList) {
        if (item is Map<String, dynamic>) {
          final time = item['time']?.toString();
          final isAvailable = item['isAvailable'] == true;
          if (time != null && time.isNotEmpty) {
            results[_slotKey(date, time)] = isAvailable;
          }
        }
      }

      if (!mounted) return;

      setState(() {
        for (final item in dataList) {
          if (item is Map<String, dynamic>) {
            final time = item['time']?.toString();
            if (time != null && time.isNotEmpty) {
              _slotAvailability[_slotKey(date, time)] =
                  results[_slotKey(date, time)] ?? false;
            }
          }
        }
        _checkingAvailability = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _checkingAvailability = false;
      });
    }
  }

  bool _isSlotEnabled(DateTime date, String slot) {
    final key = _slotKey(date, slot);
    return _slotAvailability[key] ?? true;
  }

  Future<void> _goToStaffPage() async {
    if (_submitting) return;

    if (selectedDate == null || selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ngày và giờ mới'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập lý do đổi lịch'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final canUseSlot = _isSlotEnabled(selectedDate!, selectedSlot!);
    if (!canUseSlot) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Khung giờ này không còn khả dụng'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => BookingRescheduleStaffPage(
            booking: widget.booking,
            storeId: widget.booking.storeId,
            newAppointmentDate: selectedDate!,
            newStartTime: selectedSlot!,
            reason: reason,
            rescheduleBeforeHours: widget.rescheduleBeforeHours,
          ),
        ),
      );

      if (result == true && mounted) {
        Navigator.pop(context, true);
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingDt = _bookingDateTime(widget.booking);
    final dateLabel =
        selectedDate == null ? 'Chọn ngày' : _formatDateLabel(selectedDate!);

    final availableSlots = selectedDate == null
        ? <String>[]
        : _slotAvailability.entries
            .where((e) => e.key.startsWith(
                  '${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}_',
                ))
            .map((e) => e.key.split('_').last)
            .toList()
      ..sort();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            0,
            0,
            0,
            16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                child: Row(
                  children: [
                    _backButton(),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Đổi lịch hẹn',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.pageTitle,
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Chọn ngày giờ mới cho booking',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyMuted,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.96),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                    boxShadow: AppDecorations.softShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.booking.storeName?.isNotEmpty == true
                            ? widget.booking.storeName!
                            : 'Booking #${widget.booking.id}',
                        style: AppTextStyles.body.copyWith(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        bookingDt == null
                            ? 'Chưa xác định được thời gian booking'
                            : 'Lịch hiện tại: ${DateFormat('dd/MM/yyyy HH:mm').format(bookingDt)}',
                        style: AppTextStyles.bodyMuted,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: _pickDate,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.96),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.border),
                      boxShadow: AppDecorations.softShadow,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ngày hẹn',
                                style: AppTextStyles.caption,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                dateLabel,
                                style: AppTextStyles.sectionTitle.copyWith(
                                  fontSize: 15.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Khung giờ trống',
                        style:
                            AppTextStyles.sectionTitle.copyWith(fontSize: 17),
                      ),
                    ),
                    if (selectedDate != null)
                      Text(
                        DateFormat('dd/MM/yyyy').format(selectedDate!),
                        style: AppTextStyles.caption,
                      ),
                  ],
                ),
              ),
              if (_checkingAvailability)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 16, right: 16),
                  child: Text(
                    'Đang kiểm tra khung giờ khả dụng...',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: selectedDate == null
                    ? _stateHint(
                        message: 'Hãy chọn ngày để xem giờ còn trống',
                      )
                    : availableSlots.isEmpty
                        ? _stateHint(
                            message: 'Ngày này không còn khung giờ phù hợp',
                          )
                        : GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: 4),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 2.8,
                            ),
                            itemCount: availableSlots.length,
                            itemBuilder: (context, index) {
                              final slot = availableSlots[index];
                              final selected = selectedSlot == slot;
                              final enabled =
                                  _isSlotEnabled(selectedDate!, slot);

                              return ChoiceChip(
                                label: Text(slot),
                                selected: selected,
                                onSelected: enabled
                                    ? (v) {
                                        setState(() {
                                          selectedSlot = v ? slot : null;
                                        });
                                      }
                                    : null,
                                labelStyle: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: selected
                                      ? AppColors.surface
                                      : enabled
                                          ? AppColors.textMuted
                                          : AppColors.textMuted.withValues(
                                              alpha: 0.4,
                                            ),
                                ),
                                selectedColor: AppColors.primary,
                                backgroundColor: enabled
                                    ? AppColors.surface
                                    : AppColors.surfaceSoft,
                                disabledColor: AppColors.surfaceSoft,
                                side: BorderSide(
                                  color: selected
                                      ? AppColors.primary
                                      : enabled
                                          ? AppColors.border
                                          : AppColors.borderSoft,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                showCheckmark: false,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                              );
                            },
                          ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.96),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                    boxShadow: AppDecorations.softShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lý do đổi lịch',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _reasonController,
                        maxLines: 3,
                        style: AppTextStyles.body,
                        decoration: InputDecoration(
                          hintText: 'Nhập lý do bạn muốn đổi lịch...',
                          hintStyle: AppTextStyles.bodyMuted,
                          filled: true,
                          fillColor: AppColors.surfaceSoft,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.borderSoft),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.borderSoft),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.primary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.surface,
                      disabledBackgroundColor:
                          AppColors.primary.withValues(alpha: 0.35),
                      disabledForegroundColor: AppColors.surface,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    onPressed: _submitting ? null : _goToStaffPage,
                    child: _submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.surface,
                            ),
                          )
                        : const Text(
                            'Tiếp tục',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
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

  Widget _stateHint({
    required String message,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: AppDecorations.softShadow,
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: AppTextStyles.bodyMuted,
      ),
    );
  }

  Widget _backButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: AppDecorations.topBarShadow,
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 16,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
