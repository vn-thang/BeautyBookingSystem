import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:mobile_customer/core/theme/app_colors.dart';
import 'package:mobile_customer/core/theme/app_decorations.dart';
import 'package:mobile_customer/core/theme/app_text_styles.dart';

import '../../data/models/operating_hour_model.dart';
import 'booking_staff_page.dart';

class BookingDateTimePage extends StatefulWidget {
  final int storeId;
  final String storeName;
  final List<int> services;
  final List<String> serviceNames;
  final int totalDuration;
  final List<OperatingHourViewDto> operatingHours;

  const BookingDateTimePage({
    super.key,
    required this.storeId,
    required this.storeName,
    required this.services,
    required this.serviceNames,
    required this.totalDuration,
    required this.operatingHours,
  });

  @override
  State<BookingDateTimePage> createState() => _BookingDateTimePageState();
}

class _BookingDateTimePageState extends State<BookingDateTimePage> {
  DateTime? selectedDate;
  String? selectedSlot;

  DateTime _normalizeDate(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  int _toDbDayOfWeek(DateTime date) {
    return date.weekday == DateTime.sunday ? 0 : date.weekday;
  }

  OperatingHourViewDto? _getOperatingHourForDate(DateTime date) {
    final dow = _toDbDayOfWeek(date);
    for (final item in widget.operatingHours) {
      if (item.dayOfWeek == dow) return item;
    }
    return null;
  }

  DateTime _timeOnDate(DateTime date, String hhmm) {
    final parts = hhmm.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  DateTime _roundUpToNext30Minutes(DateTime dt) {
    final minute = dt.minute;
    final rounded = ((minute + 29) ~/ 30) * 30;

    if (rounded == 60) {
      return DateTime(dt.year, dt.month, dt.day, dt.hour + 1, 0);
    }
    return DateTime(dt.year, dt.month, dt.day, dt.hour, rounded);
  }

  List<String> _getAvailableSlots(DateTime date) {
    final oh = _getOperatingHourForDate(date);
    if (oh == null) return [];

    final now = DateTime.now();
    final openTime = _timeOnDate(date, oh.openTime);
    final closeTime = _timeOnDate(date, oh.closeTime);

    DateTime startTime = openTime;

    if (_isSameDate(date, now)) {
      final minAllowed = now.add(const Duration(hours: 1));
      if (minAllowed.isAfter(startTime)) {
        startTime = minAllowed;
      }
    }

    startTime = _roundUpToNext30Minutes(startTime);

    final lastStart =
        closeTime.subtract(Duration(minutes: widget.totalDuration));
    if (startTime.isAfter(lastStart)) return [];

    final slots = <String>[];
    var cursor = startTime;

    while (!cursor.isAfter(lastStart)) {
      slots.add(DateFormat('HH:mm').format(cursor));
      cursor = cursor.add(const Duration(minutes: 30));
    }

    return slots;
  }

  DateTime? _firstSelectableDate(DateTime from) {
    final start = _normalizeDate(from);
    for (int i = 0; i <= 60; i++) {
      final day = start.add(Duration(days: i));
      if (_getAvailableSlots(day).isNotEmpty) {
        return day;
      }
    }
    return null;
  }

  String _formatDateLabel(DateTime date) {
    const weekdays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    final weekday =
        weekdays[date.weekday == DateTime.sunday ? 6 : date.weekday - 1];
    return '$weekday, ${DateFormat('dd/MM/yyyy').format(date)}';
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final firstSelectable = _firstSelectableDate(now);

    if (firstSelectable == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hiện không có ngày nào còn khung giờ phù hợp'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final safeInitialDate =
        selectedDate != null && _getAvailableSlots(selectedDate!).isNotEmpty
            ? selectedDate!
            : firstSelectable;

    final picked = await showDatePicker(
      context: context,
      firstDate: _normalizeDate(now),
      lastDate: _normalizeDate(now.add(const Duration(days: 60))),
      initialDate: safeInitialDate,
      selectableDayPredicate: (day) {
        final normalized = _normalizeDate(day);
        return _getAvailableSlots(normalized).isNotEmpty;
      },
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

    if (picked != null) {
      setState(() {
        selectedDate = _normalizeDate(picked);
        selectedSlot = null;
      });
    }
  }

  void _goToConfirm() {
    if (selectedDate == null || selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ngày và giờ'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingStaffPage(
          storeId: widget.storeId,
          services: widget.services,
          appointmentDate: selectedDate!,
          startTime: selectedSlot!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = selectedDate == null
        ? 'Chưa chọn ngày'
        : _formatDateLabel(selectedDate!);

    final availableSlots =
        selectedDate == null ? <String>[] : _getAvailableSlots(selectedDate!);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppDecorations.pageGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                child: Row(
                  children: [
                    _backButton(context),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chọn ngày giờ',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.pageTitle,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.storeName,
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
                    color: AppColors.surface.withOpacity(0.96),
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
                              widget.serviceNames.isEmpty
                                  ? 'Chưa chọn dịch vụ'
                                  : '${widget.serviceNames.length} dịch vụ đã chọn',
                              style: AppTextStyles.body.copyWith(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              widget.serviceNames.isEmpty
                                  ? 'Quay lại để chọn dịch vụ'
                                  : widget.serviceNames.join(', '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodyMuted,
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _miniChip(
                                  text: '${widget.totalDuration} phút',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
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
                      color: AppColors.surface.withOpacity(0.96),
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
              const SizedBox(height: 10),
              Expanded(
                child: Padding(
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
                              padding: const EdgeInsets.only(bottom: 16),
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

                                return ChoiceChip(
                                  label: Text(slot),
                                  selected: selected,
                                  onSelected: (v) {
                                    setState(() {
                                      selectedSlot = v ? slot : null;
                                    });
                                  },
                                  labelStyle: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: selected
                                        ? AppColors.surface
                                        : AppColors.textMuted,
                                  ),
                                  selectedColor: AppColors.primary,
                                  backgroundColor: AppColors.surface,
                                  side: BorderSide(
                                    color: selected
                                        ? AppColors.primary
                                        : AppColors.border,
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
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.98),
            border: Border(
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
                      label: 'Ngày',
                      value: selectedDate == null
                          ? 'Chưa chọn'
                          : DateFormat('dd/MM/yyyy').format(selectedDate!),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _summaryTile(
                      label: 'Giờ',
                      value: selectedSlot ?? 'Chưa chọn',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.surface,
                    disabledBackgroundColor:
                        AppColors.primary.withOpacity(0.35),
                    disabledForegroundColor: AppColors.surface,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  onPressed: (selectedDate != null && selectedSlot != null)
                      ? _goToConfirm
                      : null,
                  child: const Text(
                    'Tiếp tục',
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
    );
  }

  Widget _miniChip({
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textMuted,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _summaryTile({
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
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stateHint({
    required String message,
  }) {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.96),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: AppDecorations.softShadow,
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMuted,
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
          color: AppColors.surface.withOpacity(0.96),
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
