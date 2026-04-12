import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import 'package:mobile_customer/core/theme/app_colors.dart';
import 'package:mobile_customer/core/theme/app_decorations.dart';
import 'package:mobile_customer/core/theme/app_text_styles.dart';
import 'package:mobile_customer/injection/service_locator.dart' as di;

import '../../data/models/booking_models.dart';
import 'booking_reschedule_confirm_page.dart';

class BookingRescheduleStaffPage extends StatefulWidget {
  final BookingItem booking;
  final int storeId;
  final DateTime newAppointmentDate;
  final String newStartTime;
  final String reason;
  final int rescheduleBeforeHours;

  const BookingRescheduleStaffPage({
    super.key,
    required this.booking,
    required this.storeId,
    required this.newAppointmentDate,
    required this.newStartTime,
    required this.reason,
    required this.rescheduleBeforeHours,
  });

  @override
  State<BookingRescheduleStaffPage> createState() =>
      _BookingRescheduleStaffPageState();
}

class _BookingRescheduleStaffPageState
    extends State<BookingRescheduleStaffPage> {
  bool loading = true;
  String? error;

  List<Map<String, dynamic>> staffs = [];
  int? selectedStaffId;

  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  Future<void> _loadStaff() async {
    try {
      final dio = di.sl<Dio>();

      final serviceIds =
          widget.booking.services.map((e) => e.serviceId).toList();

      final resp = await dio.post(
        'bookings/available-staff',
        data: {
          'storeId': widget.storeId,
          'serviceIds': serviceIds,
          'appointmentDate':
              DateFormat('yyyy-MM-dd').format(widget.newAppointmentDate),
          'startTime': widget.newStartTime,
          'excludeBookingId': widget.booking.id,
        },
      );

      final data = List<Map<String, dynamic>>.from(resp.data);

      if (!mounted) return;
      setState(() {
        staffs = data;
        loading = false;
        selectedStaffId = null;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = e.response?.data?.toString() ?? 'Lỗi kết nối: ${e.message}';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = e.toString();
      });
    }
  }

  void _goNext() {
    String? selectedStaffName;

    if (selectedStaffId != null) {
      final staff = staffs.firstWhere(
        (s) => s['id'] == selectedStaffId,
        orElse: () => <String, dynamic>{},
      );
      selectedStaffName = staff['name']?.toString();
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingRescheduleConfirmPage(
          booking: widget.booking,
          newAppointmentDate: widget.newAppointmentDate,
          newStartTime: widget.newStartTime,
          selectedStaffId: selectedStaffId,
          selectedStaffName: selectedStaffName,
          reason: widget.reason,
          rescheduleBeforeHours: widget.rescheduleBeforeHours,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel =
        DateFormat('dd/MM/yyyy').format(widget.newAppointmentDate);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Row(
                children: [
                  _backButton(),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chọn nhân viên',
                          style: AppTextStyles.pageTitle,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$dateLabel • ${widget.newStartTime}',
                          style: AppTextStyles.bodyMuted,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (loading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            else if (error != null)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(error!, textAlign: TextAlign.center),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: [
                    _sectionHeader('Lựa chọn nhanh'),
                    const SizedBox(height: 10),
                    _optionCard(
                      selected: selectedStaffId == null,
                      onTap: () => setState(() => selectedStaffId = null),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bất kỳ nhân viên nào',
                                  style: AppTextStyles.body.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Hệ thống sẽ chọn nhân viên phù hợp nhất.',
                                  style: AppTextStyles.bodyMuted,
                                ),
                              ],
                            ),
                          ),
                          Radio<int?>(
                            value: null,
                            groupValue: selectedStaffId,
                            onChanged: (_) =>
                                setState(() => selectedStaffId = null),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _sectionHeader('Danh sách nhân viên'),
                    const SizedBox(height: 10),
                    if (staffs.isEmpty)
                      _emptyCard()
                    else
                      ...staffs.map((s) {
                        final staffId = s['id'] as int;
                        final name = (s['name'] ?? '').toString();
                        final avatar = (s['avatarUrl'] ?? '').toString();
                        final selected = selectedStaffId == staffId;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _optionCard(
                            selected: selected,
                            onTap: () =>
                                setState(() => selectedStaffId = staffId),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 21,
                                  backgroundColor: AppColors.surfaceSoft,
                                  backgroundImage: avatar.isNotEmpty
                                      ? NetworkImage(avatar)
                                      : null,
                                  child: avatar.isEmpty
                                      ? Text(_initials(name))
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: AppTextStyles.body.copyWith(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        selected ? 'Đã chọn' : 'Nhấn để chọn',
                                        style: AppTextStyles.bodyMuted,
                                      ),
                                    ],
                                  ),
                                ),
                                Radio<int?>(
                                  value: staffId,
                                  groupValue: selectedStaffId,
                                  onChanged: (v) =>
                                      setState(() => selectedStaffId = v),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: _goNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Tiếp tục',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) => Text(
        title,
        style: AppTextStyles.sectionTitle.copyWith(fontSize: 17),
      );

  Widget _optionCard({
    required bool selected,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
          boxShadow: AppDecorations.softShadow,
        ),
        child: child,
      ),
    );
  }

  Widget _emptyCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: const Text(
        'Chưa có nhân viên phù hợp cho khung giờ này.',
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _backButton() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
      ),
    );
  }

  String _initials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return 'S';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}
