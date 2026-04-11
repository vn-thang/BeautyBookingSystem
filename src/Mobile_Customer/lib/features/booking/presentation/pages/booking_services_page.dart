import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import 'package:mobile_customer/core/theme/app_colors.dart';
import 'package:mobile_customer/core/theme/app_decorations.dart';
import 'package:mobile_customer/core/theme/app_text_styles.dart';
import 'package:mobile_customer/injection/service_locator.dart' as di;

import '../../data/models/operating_hour_model.dart';
import '../pages/booking_datetime_page.dart';

class BookingServicesPage extends StatefulWidget {
  final int storeId;
  final int selectedServiceId;

  const BookingServicesPage({
    super.key,
    required this.storeId,
    required this.selectedServiceId,
  });

  @override
  State<BookingServicesPage> createState() => _BookingServicesPageState();
}

class _BookingServicesPageState extends State<BookingServicesPage> {
  final NumberFormat _moneyFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'đ',
    decimalDigits: 0,
  );

  List<Map<String, dynamic>> services = [];
  List<OperatingHourViewDto> operatingHours = [];

  List<int> selectedServices = [];
  List<String> selectedServiceNames = [];

  String storeName = '';

  double totalPrice = 0;
  int totalDuration = 0;

  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadStoreServices();
  }

  String _formatMoney(num value) => _moneyFormat.format(value);

  Future<void> _loadStoreServices() async {
    try {
      final dio = di.sl<Dio>();

      final resp = await dio.get('customer/stores/${widget.storeId}');
      final data = resp.data;

      final svc = (data['services'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();

      final oh = (data['operatingHours'] as List<dynamic>? ?? [])
          .map(
            (e) => OperatingHourViewDto.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList();

      setState(() {
        services = svc;
        operatingHours = oh;
        storeName = (data['name'] as String?) ?? '';

        if (services.any((s) => s['id'] == widget.selectedServiceId)) {
          final init = services.firstWhere(
            (s) => s['id'] == widget.selectedServiceId,
          );

          selectedServices = [widget.selectedServiceId];
          selectedServiceNames = [(init['name'] as String?) ?? ''];

          totalPrice = ((init['price'] as num?) ?? 0).toDouble();
          totalDuration = (init['durationMinutes'] as num?)?.toInt() ?? 0;
        } else {
          selectedServices = [];
          selectedServiceNames = [];
          totalPrice = 0;
          totalDuration = 0;
        }

        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  void _onToggle(
    int id,
    String name,
    double price,
    int duration,
    bool add,
  ) {
    setState(() {
      if (add) {
        if (!selectedServices.contains(id)) {
          selectedServices.add(id);
          selectedServiceNames.add(name);
          totalPrice += price;
          totalDuration += duration;
        }
      } else {
        if (selectedServices.contains(id)) {
          selectedServices.remove(id);
          selectedServiceNames.remove(name);
          totalPrice -= price;
          totalDuration -= duration;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppDecorations.pageGradient,
          ),
          child: const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          ),
        ),
      );
    }

    if (error != null) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppDecorations.pageGradient,
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppDecorations.cardShadow,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Không thể tải dịch vụ',
                      style: AppTextStyles.sectionTitle.copyWith(fontSize: 17),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Lỗi: $error',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMuted.copyWith(height: 1.45),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: _loadStoreServices,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.surface,
                          padding: EdgeInsets.zero,
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
        ),
      );
    }

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
                            'Chọn dịch vụ',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.pageTitle,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            storeName.isEmpty ? 'Danh sách dịch vụ' : storeName,
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
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedServices.isEmpty
                                  ? 'Chưa chọn dịch vụ'
                                  : '${selectedServices.length} dịch vụ đã chọn',
                              style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 14.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              selectedServices.isEmpty
                                  ? 'Chọn ít nhất 1 dịch vụ để tiếp tục'
                                  : selectedServiceNames.join(', '),
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
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: services.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final s = services[index];

                    final id = s['id'] as int;
                    final name = s['name'] as String;
                    final price = (s['price'] as num).toDouble();
                    final duration = s['durationMinutes'] as int;
                    final selected = selectedServices.contains(id);

                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _onToggle(
                        id,
                        name,
                        price,
                        duration,
                        !selected,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.96),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color:
                                selected ? AppColors.primary : AppColors.border,
                            width: selected ? 1.1 : 1,
                          ),
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.08),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ]
                              : AppDecorations.softShadow,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: selected,
                              onChanged: (v) => _onToggle(
                                id,
                                name,
                                price,
                                duration,
                                v == true,
                              ),
                              activeColor: AppColors.primary,
                              checkColor: AppColors.surface,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.body.copyWith(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14.5,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      _miniChip(
                                        text: _formatMoney(price),
                                      ),
                                      _miniChip(
                                        text: '$duration phút',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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
                      label: 'Tổng tiền',
                      value: _formatMoney(totalPrice),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _summaryTile(
                      label: 'Tổng thời gian',
                      value: '$totalDuration phút',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 42,
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
                  onPressed: selectedServices.isEmpty
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BookingDateTimePage(
                                storeId: widget.storeId,
                                storeName: storeName,
                                services: selectedServices,
                                serviceNames: selectedServiceNames,
                                totalDuration: totalDuration,
                                operatingHours: operatingHours,
                              ),
                            ),
                          );
                        },
                  child: Text(
                    'Tiếp tục • ${_formatMoney(totalPrice)}',
                    style: const TextStyle(
                      fontSize: 14.2,
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

  Widget _summaryTile({
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
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
            style: AppTextStyles.body.copyWith(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniChip({
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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

  Widget _backButton(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: AppDecorations.topBarShadow,
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 15,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
