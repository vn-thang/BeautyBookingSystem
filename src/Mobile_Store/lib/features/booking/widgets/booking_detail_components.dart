import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart'; 
import '../models/store_booking_model.dart';

class CustomCardContainer extends StatelessWidget {
  final String title;
  final Widget child;

  const CustomCardContainer({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
        boxShadow: [
          BoxShadow(
            color: AppColors.textMain.withValues(alpha: 0.03), 
            blurRadius: 8, 
            offset: const Offset(0, 2),
          )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title, 
            style: AppTextStyles.bodyText.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const InfoRow({super.key, required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.textSub),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.labelSmall),
              const SizedBox(height: AppSpacing.xs),
              Text(
                value, 
                style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.w500, fontSize: 15),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class BookingStatusBanner extends StatelessWidget {
  final StoreBookingDetailModel detail;
  const BookingStatusBanner({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    String statusText;
    switch (detail.status.toLowerCase()) {
      case 'pending': 
        bgColor = AppColors.warning; 
        statusText = 'Đang chờ duyệt'; 
        break;
      case 'confirmed': 
        bgColor = const Color(0xFF0068FF); 
        statusText = 'Đã xác nhận'; 
        break;
      case 'completed': 
        bgColor = AppColors.success; 
        statusText = 'Đã hoàn thành'; 
        break;
      case 'cancelled': 
        bgColor = AppColors.error; 
        statusText = 'Đã hủy (${detail.cancelReason ?? 'Không rõ'})'; 
        break;
      default: 
        bgColor = AppColors.textSub; 
        statusText = 'Không rõ';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.paddingMedium),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.1), 
        borderRadius: BorderRadius.circular(AppDimens.radiusSmall), 
        border: Border.all(color: bgColor.withValues(alpha: 0.3))
      ),
      child: Text(
        'Trạng thái: $statusText',
        style: AppTextStyles.bodyText.copyWith(color: bgColor, fontWeight: FontWeight.bold, fontSize: 15),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class CustomerSection extends StatelessWidget {
  final StoreBookingDetailModel detail;
  const CustomerSection({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    return CustomCardContainer(
      title: 'Thông tin khách hàng',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoRow(icon: Icons.person_outline, label: 'Khách hàng', value: detail.customerName),
          const SizedBox(height: AppSpacing.md),
          InfoRow(icon: Icons.phone_outlined, label: 'Số điện thoại', value: detail.customerPhone),
          if (detail.customerNote != null && detail.customerNote!.isNotEmpty) ...[
            const Padding(padding: EdgeInsets.symmetric(vertical: AppSpacing.md), child: Divider(height: 1, color: AppColors.surface)),
            InfoRow(icon: Icons.edit_note, label: 'Ghi chú', value: detail.customerNote!),
          ]
        ],
      ),
    );
  }
}

class ServicesSection extends StatelessWidget {
  final StoreBookingDetailModel detail;
  const ServicesSection({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    return CustomCardContainer(
      title: 'Dịch vụ đã chọn (${detail.services.length})',
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: detail.services.length,
        separatorBuilder: (context, index) => const Divider(height: AppDimens.paddingLarge, color: AppColors.surface),
        itemBuilder: (context, index) {
          final service = detail.services[index];
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(
                  color: AppColors.surface, 
                  borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                ),
                child: const Icon(Icons.spa_outlined, color: AppColors.textSub),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.serviceName, 
                      style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${service.startTime} - ${service.endTime} • ${Formatters.formatDateOnly(service.appointmentDate)}',
                      style: AppTextStyles.labelSmall.copyWith(fontSize: 13),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Nhân viên: ${service.staffName ?? "Chưa phân công"}',
                      style: AppTextStyles.bodyText.copyWith(
                        color: service.staffName == null ? AppColors.warning : const Color(0xFF0068FF), 
                        fontSize: 13, 
                        fontWeight: FontWeight.w500
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                Formatters.formatCurrency(service.price), 
                style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ],
          );
        },
      ),
    );
  }
}

class PaymentSection extends StatelessWidget {
  final StoreBookingDetailModel detail;
  const PaymentSection({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    return CustomCardContainer(
      title: 'Chi tiết thanh toán',
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tổng tạm tính', style: AppTextStyles.bodyText.copyWith(color: AppColors.textSub)),
              Text(
                Formatters.formatCurrency(detail.totalPrice), 
                style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Khuyến mãi', style: AppTextStyles.bodyText.copyWith(color: AppColors.textSub)),
              Text(
                '- ${Formatters.formatCurrency(detail.discountAmount)}', 
                style: AppTextStyles.bodyText.copyWith(color: AppColors.success, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: AppSpacing.sm), child: Divider(height: 1, color: AppColors.surface)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tổng cộng', style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(
                Formatters.formatCurrency(detail.finalPrice), 
                style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Đã cọc', style: AppTextStyles.bodyText.copyWith(color: AppColors.textSub)),
              Text(
                '- ${Formatters.formatCurrency(detail.depositAmount)}', 
                style: AppTextStyles.bodyText.copyWith(color: AppColors.warning, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: AppSpacing.sm), child: Divider(height: 1, color: AppColors.surface)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Cần thanh toán', style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(
                Formatters.formatCurrency(detail.remainingAmount), 
                style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}