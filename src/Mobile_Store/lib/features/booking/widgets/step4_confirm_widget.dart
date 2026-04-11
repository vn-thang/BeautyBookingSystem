import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/models/service_model.dart';
import '../models/store_booking_model.dart'; 

class Step4ConfirmWidget extends StatelessWidget {
  final List<ServiceModel> selectedServices;
  final DateTime? selectedDate;
  final String? selectedTime;
  final int? selectedStaffId;
  final List<AvailableStaffModel> availableStaffs;
  final TextEditingController customerNameController;
  final TextEditingController customerPhoneController;

  const Step4ConfirmWidget({
    super.key,
    required this.selectedServices,
    required this.selectedDate,
    required this.selectedTime,
    required this.selectedStaffId,
    required this.availableStaffs,
    required this.customerNameController,
    required this.customerPhoneController,
  });

  @override
  Widget build(BuildContext context) {
    int totalMinutes = selectedServices.fold<int>(0, (int sum, item) => sum + item.durationMinutes);
    double totalPrice = selectedServices.fold<double>(0, (double sum, item) => sum + item.price);
    final currencyFormatter = NumberFormat.currency(locale: 'vi', symbol: 'đ');

    String displayDate = selectedDate != null ? DateFormat('dd/MM/yyyy').format(selectedDate!) : 'Chưa chọn';
    String displayTime = selectedTime ?? 'Chưa chọn';

    String staffName = 'Bất kỳ';
    if (selectedStaffId != null && availableStaffs.isNotEmpty) {
      try {
        staffName = availableStaffs.firstWhere((s) => s.id == selectedStaffId).fullName;
      } catch (_) {
        staffName = 'Đã chọn thợ';
      }
    }

    return ListView(
      padding: const EdgeInsets.all(AppDimens.paddingMedium),
      children: [
        Container(
          padding: const EdgeInsets.all(AppDimens.paddingMedium),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
            border: Border.all(color: AppColors.surface),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Thông tin khách hàng', style: AppTextStyles.heading1.copyWith(fontSize: 16)),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: customerNameController,
                decoration: InputDecoration(
                  labelText: 'Tên khách hàng (*)',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimens.radiusSmall)),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: customerPhoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Số điện thoại (Tùy chọn)',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimens.radiusSmall)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        Text('Chi tiết lịch hẹn', style: AppTextStyles.heading1.copyWith(fontSize: 16)),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.all(AppDimens.paddingMedium),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
            border: Border.all(color: AppColors.surface),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildDetailTile('Ngày hẹn', displayDate)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: _buildDetailTile('Giờ hẹn', displayTime)),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(child: _buildDetailTile('Tổng thời gian', '$totalMinutes phút')),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: _buildDetailTile('Nhân viên', staffName)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        Text('Dịch vụ', style: AppTextStyles.heading1.copyWith(fontSize: 16)),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.all(AppDimens.paddingMedium),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
            border: Border.all(color: AppColors.surface),
          ),
          child: Column(
            children: selectedServices.map((service) => _buildServiceItem(service)).toList(),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            Expanded(
              child: Card(
                elevation: 0,
                color: AppColors.primary.withValues(alpha: 0.05),
                shape: RoundedRectangleBorder(side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)), borderRadius: BorderRadius.circular(AppDimens.radiusMedium)),
                child: Padding(
                  padding: const EdgeInsets.all(AppDimens.paddingMedium),
                  child: Column(
                    children: [
                      Text('Cần thanh toán', style: AppTextStyles.bodyText.copyWith(color: AppColors.textSub)),
                      const SizedBox(height: AppSpacing.xs),
                     Text(currencyFormatter.format(totalPrice), style: AppTextStyles.heading1.copyWith(fontSize: 18, color: AppColors.primary)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Card(
                elevation: 0,
                color: AppColors.primary.withValues(alpha: 0.05),
                shape: RoundedRectangleBorder(side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)), borderRadius: BorderRadius.circular(AppDimens.radiusMedium)),
                child: Padding(
                  padding: const EdgeInsets.all(AppDimens.paddingMedium),
                  child: Column(
                    children: [
                      Text('Hình thức', style: AppTextStyles.bodyText.copyWith(color: AppColors.textSub)),
                      const SizedBox(height: AppSpacing.xs),
                      Text('COD', style: AppTextStyles.heading1.copyWith(fontSize: 18, color: AppColors.primary)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        
      ],
    );
  }
  Widget _buildDetailTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
        border: Border.all(color: AppColors.surface),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.bodyText.copyWith(color: AppColors.textSub, fontSize: 12)),
          const SizedBox(height: AppSpacing.xs),
          Text(value, style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildServiceItem(ServiceModel service) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi', symbol: 'đ');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(service.name, style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSpacing.xs),
              Text('${service.durationMinutes} phút', style: AppTextStyles.bodyText.copyWith(color: AppColors.textSub)),
            ],
          ),
          Text(currencyFormatter.format(service.price), style: AppTextStyles.heading1.copyWith(fontSize: 16, color: AppColors.primary)),
        ],
      ),
    );
  }
}