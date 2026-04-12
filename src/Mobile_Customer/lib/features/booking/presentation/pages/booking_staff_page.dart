import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import 'package:mobile_customer/core/theme/app_colors.dart';
import 'package:mobile_customer/core/theme/app_decorations.dart';
import 'package:mobile_customer/core/theme/app_text_styles.dart';
import 'package:mobile_customer/injection/service_locator.dart' as di;

import 'booking_confirm_page.dart';

class BookingStaffPage extends StatefulWidget {
  final int storeId;
  final List<int> services;
  final DateTime appointmentDate;
  final String startTime;

  const BookingStaffPage({
    super.key,
    required this.storeId,
    required this.services,
    required this.appointmentDate,
    required this.startTime,
  });

  @override
  State<BookingStaffPage> createState() => _BookingStaffPageState();
}

class _BookingStaffPageState extends State<BookingStaffPage> {
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

      // Đưa data ra một biến riêng để dễ log
      final requestData = {
        "storeId": widget.storeId,
        "serviceIds":
            widget.services, // Thay bằng serviceIds và gửi nguyên cái list
        "appointmentDate":
            DateFormat('yyyy-MM-dd').format(widget.appointmentDate),
        "startTime": widget.startTime,
      };

      print('=== BẮT ĐẦU GỌI API: bookings/available-staff ===');
      print('Data gửi lên: $requestData');

      final resp = await dio.post(
        'bookings/available-staff',
        data: requestData,
      );

      final data = List<Map<String, dynamic>>.from(resp.data);

      setState(() {
        staffs = data;
        loading = false;
        selectedStaffId = null;
      });
    } on DioException catch (e) {
      // BẮT LỖI TỪ API (Ví dụ: 400 Bad Request)
      print('=== LỖI TỪ BACKEND (DIO EXCEPTION) ===');
      print('Status Code: ${e.response?.statusCode}');
      print('Data đã gửi: ${e.requestOptions.data}');
      print('Backend trả về: ${e.response?.data}');
      print('=======================================');

      setState(() {
        loading = false;
        // Ưu tiên hiển thị thông báo lỗi chi tiết từ backend thay vì lỗi chung chung
        error = e.response?.data?.toString() ?? 'Lỗi kết nối: ${e.message}';
      });
    } catch (e) {
      // BẮT CÁC LỖI KHÁC (Ví dụ: Lỗi parse JSON, lỗi logic)
      print('=== LỖI KHÔNG XÁC ĐỊNH ===');
      print('Chi tiết: $e');
      print('==========================');

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
        builder: (_) => BookingConfirmPage(
          storeId: widget.storeId,
          services: widget.services,
          appointmentDate: widget.appointmentDate,
          startTime: widget.startTime,
          staffId: selectedStaffId,
          staffName: selectedStaffName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('dd/MM/yyyy').format(widget.appointmentDate);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppDecorations.pageGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                child: Row(
                  children: [
                    _backButton(context),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chọn nhân viên',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.pageTitle,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$dateLabel • ${widget.startTime}',
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
              const SizedBox(height: 12),
              if (loading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  ),
                )
              else if (error != null)
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 20),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.96),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: AppColors.border),
                          boxShadow: AppDecorations.cardShadow,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Không thể tải nhân viên',
                              style: AppTextStyles.sectionTitle
                                  .copyWith(fontSize: 17),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              error!,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMuted
                                  .copyWith(height: 1.45),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 44,
                              child: ElevatedButton(
                                onPressed: _loadStaff,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.surface,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
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
                        onTap: () {
                          setState(() {
                            selectedStaffId = null;
                          });
                        },
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bất kỳ nhân viên nào',
                                    style: AppTextStyles.body.copyWith(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Hệ thống sẽ tự sắp xếp nhân viên phù hợp nhất.',
                                    style: AppTextStyles.bodyMuted.copyWith(
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Radio<int?>(
                              value: null,
                              groupValue: selectedStaffId,
                              activeColor: AppColors.primary,
                              onChanged: (_) {
                                setState(() {
                                  selectedStaffId = null;
                                });
                              },
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
                          final int staffId = s['id'] as int;
                          final String name = (s['name'] ?? '').toString();
                          final String avatar =
                              (s['avatarUrl'] ?? '').toString();
                          final bool selected = selectedStaffId == staffId;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _optionCard(
                              selected: selected,
                              onTap: () {
                                setState(() {
                                  selectedStaffId = staffId;
                                });
                              },
                              child: Row(
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.surfaceSoft,
                                      border: Border.all(
                                        color: selected
                                            ? AppColors.primary
                                            : AppColors.border,
                                      ),
                                    ),
                                    child: ClipOval(
                                      child: avatar.isNotEmpty
                                          ? Image.network(
                                              avatar,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  _avatarFallback(name),
                                            )
                                          : _avatarFallback(name),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTextStyles.body.copyWith(
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          selected ? 'Đã chọn' : 'Nhấn để chọn',
                                          style:
                                              AppTextStyles.bodyMuted.copyWith(
                                            color: selected
                                                ? AppColors.primary
                                                : AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Radio<int?>(
                                    value: staffId,
                                    groupValue: selectedStaffId,
                                    activeColor: AppColors.primary,
                                    onChanged: (v) {
                                      setState(() {
                                        selectedStaffId = v;
                                      });
                                    },
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
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.98),
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
                      value: dateLabel,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _summaryTile(
                      label: 'Giờ',
                      value: widget.startTime,
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
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _goNext,
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

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.sectionTitle.copyWith(fontSize: 17),
    );
  }

  Widget _optionCard({
    required bool selected,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 1.1 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : AppDecorations.softShadow,
          ),
          child: child,
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

  Widget _avatarFallback(String name) {
    final initials = _initials(name);
    return Container(
      color: AppColors.primary.withValues(alpha: 0.08),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: AppTextStyles.sectionTitle.copyWith(
          fontSize: 14,
          color: AppColors.primary,
        ),
      ),
    );
  }

  String _initials(String name) {
    final source = name.trim();
    if (source.isEmpty) return 'S';

    final parts =
        source.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return source[0].toUpperCase();
    if (parts.length == 1) return parts.first[0].toUpperCase();

    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  Widget _backButton(BuildContext context) {
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

  Widget _emptyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: AppDecorations.softShadow,
      ),
      child: Text(
        'Chưa có nhân viên phù hợp cho khung giờ này.',
        textAlign: TextAlign.center,
        style: AppTextStyles.bodyMuted.copyWith(height: 1.45),
      ),
    );
  }
}
