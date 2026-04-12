import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import 'package:mobile_customer/core/theme/app_colors.dart';
import 'package:mobile_customer/core/theme/app_decorations.dart';
import 'package:mobile_customer/core/theme/app_text_styles.dart';
import 'package:mobile_customer/injection/service_locator.dart' as di;

import '../../data/models/booking_models.dart';

class BookingRescheduleConfirmPage extends StatefulWidget {
  final BookingItem booking;
  final DateTime newAppointmentDate;
  final String newStartTime;
  final int? selectedStaffId;
  final String? selectedStaffName;
  final String reason;
  final int rescheduleBeforeHours;

  const BookingRescheduleConfirmPage({
    super.key,
    required this.booking,
    required this.newAppointmentDate,
    required this.newStartTime,
    required this.selectedStaffId,
    required this.selectedStaffName,
    required this.reason,
    required this.rescheduleBeforeHours,
  });

  @override
  State<BookingRescheduleConfirmPage> createState() =>
      _BookingRescheduleConfirmPageState();
}

class _BookingRescheduleConfirmPageState
    extends State<BookingRescheduleConfirmPage> {
  bool _submitting = false;

  DateTime? _oldBookingDateTime(BookingItem item) {
    if (item.services.isEmpty) return null;
    final s = item.services.first;
    final parts = s.startTime.split(':');
    if (parts.length < 2) return s.appointmentDate;
    return DateTime(
      s.appointmentDate.year,
      s.appointmentDate.month,
      s.appointmentDate.day,
      int.tryParse(parts[0]) ?? 0,
      int.tryParse(parts[1]) ?? 0,
    );
  }

  Future<void> _confirm() async {
    if (_submitting) return;

    setState(() => _submitting = true);

    try {
      final dio = di.sl<Dio>();
      final resp = await dio.put(
        'bookings/${widget.booking.id}/reschedule',
        data: {
          'newAppointmentDate':
              DateFormat('yyyy-MM-dd').format(widget.newAppointmentDate),
          'newStartTime': widget.newStartTime,
          'newStaffId': widget.selectedStaffId,
          'reason': widget.reason,
        },
      );

      final data = resp.data;
      final ok = data is Map<String, dynamic> ? data['success'] == true : true;

      if (!mounted) return;

      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dời lịch thành công'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.success,
          ),
        );

        await Future.delayed(const Duration(milliseconds: 300));
        if (!mounted) return;

        context.go('/'); // đổi path này nếu route home của bạn khác
      } else {
        throw Exception(data.toString());
      }
    } on DioException catch (e) {
      if (!mounted) return;
      String message = 'Dời lịch thất bại';
      final data = e.response?.data;

      if (data is Map<String, dynamic>) {
        message = data['message'] ?? data['detail'] ?? data['title'] ?? message;
      } else if (data != null) {
        message = data.toString();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.danger,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dời lịch thất bại: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final oldDt = _oldBookingDateTime(widget.booking);
    final newDt = DateTime(
      widget.newAppointmentDate.year,
      widget.newAppointmentDate.month,
      widget.newAppointmentDate.day,
      int.parse(widget.newStartTime.split(':')[0]),
      int.parse(widget.newStartTime.split(':')[1]),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
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
                          'Xác nhận dời lịch',
                          style: AppTextStyles.pageTitle,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Kiểm tra lại thông tin trước khi gửi',
                          style: AppTextStyles.bodyMuted,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                children: [
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Thông tin cũ',
                          style:
                              AppTextStyles.sectionTitle.copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          oldDt == null
                              ? '-'
                              : DateFormat('dd/MM/yyyy HH:mm').format(oldDt),
                          style: AppTextStyles.bodyMuted,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Nhân viên hiện tại: ${widget.booking.staffName ?? 'Bất kỳ'}',
                          style: AppTextStyles.bodyMuted,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Thông tin mới',
                          style:
                              AppTextStyles.sectionTitle.copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          DateFormat('dd/MM/yyyy HH:mm').format(newDt),
                          style: AppTextStyles.body
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Nhân viên: ${widget.selectedStaffName ?? 'Bất kỳ'}',
                          style: AppTextStyles.bodyMuted,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Lý do: ${widget.reason}',
                          style: AppTextStyles.bodyMuted,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _confirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.surface,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _submitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.surface,
                            ),
                          )
                        : const Text(
                            'Xác nhận dời lịch',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
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
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 17),
      ),
    );
  }
}
