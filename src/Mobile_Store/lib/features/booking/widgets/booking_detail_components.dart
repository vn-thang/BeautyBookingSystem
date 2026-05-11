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

  const CustomCardContainer({
    super.key,
    required this.title,
    required this.child,
  });

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
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.bodyText.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
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
  final Color? valueColor;

  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

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
                style: AppTextStyles.bodyText.copyWith(
                  fontWeight: FontWeight.w500,
                  color: valueColor ?? AppColors.textMain,
                ),
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
      case 'depositpaid':
        bgColor = const Color.fromARGB(255, 13, 141, 135);
        statusText = 'Đã đặt cọc';
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
        border: Border.all(color: bgColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        'Trạng thái: $statusText',
        textAlign: TextAlign.center,
        style: AppTextStyles.bodyText.copyWith(
          fontWeight: FontWeight.bold,
          color: bgColor,
        ),
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
        children: [
          InfoRow(
            icon: Icons.person_outline,
            label: 'Khách hàng',
            value: detail.customerName,
          ),
          const SizedBox(height: AppSpacing.md),
          InfoRow(
            icon: Icons.phone_outlined,
            label: 'Số điện thoại',
            value: detail.customerPhone,
          ),
          if (detail.customerNote != null &&
              detail.customerNote!.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Divider(height: 1, color: AppColors.surface),
            ),
            InfoRow(
              icon: Icons.edit_note,
              label: 'Ghi chú',
              value: detail.customerNote!,
            ),
          ],
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
        separatorBuilder: (_, _) => const Divider(
          height: AppDimens.paddingLarge,
          color: AppColors.surface,
        ),
        itemBuilder: (context, index) {
          final service = detail.services[index];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(
                        AppDimens.radiusSmall,
                      ),
                    ),
                    child: const Icon(
                      Icons.spa_outlined,
                      color: AppColors.textSub,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.serviceName,
                          style: AppTextStyles.bodyText.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          Formatters.formatCurrency(service.price),
                          style: AppTextStyles.bodyText.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              InfoRow(
                icon: Icons.calendar_today_outlined,
                label: 'Ngày',
                value: Formatters.formatDateOnly(service.appointmentDate),
              ),
              InfoRow(
                icon: Icons.access_time_outlined,
                label: 'Giờ',
                value: '${service.startTime} - ${service.endTime}',
              ),
              InfoRow(
                icon: Icons.person_outline,
                label: 'Nhân viên',
                value: service.staffName ?? "Chưa phân công",
                valueColor: service.staffName == null
                    ? AppColors.warning
                    : const Color(0xFF0068FF),
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

  Widget _row(
    String label,
    String value, {
    Color? valueColor,
    bool bold = false,
  }) {
    return Row(
      children: [
        Expanded(child: Text(label, style: AppTextStyles.labelSmall)),
        const SizedBox(width: 8),
        Text(
          value,
          style: AppTextStyles.bodyText.copyWith(
            fontWeight: bold ? FontWeight.bold : FontWeight.w500,
            color: valueColor ?? AppColors.textMain,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isFullyPaid = detail.remainingAmount <= 0;

    final double extraPaidAmount =
        (detail.finalPrice - detail.remainingAmount) - detail.depositAmount;

    return CustomCardContainer(
      title: 'Chi tiết thanh toán',
      child: Column(
        children: [
          _row('Tổng giá', Formatters.formatCurrency(detail.totalPrice)),

          if (detail.discountAmount > 0) ...[
            const SizedBox(height: AppSpacing.sm),
            _row(
              'Khuyến mãi',
              '- ${Formatters.formatCurrency(detail.discountAmount)}',
              valueColor: AppColors.success,
            ),
          ],

          if (detail.depositAmount > 0) ...[
            const SizedBox(height: AppSpacing.sm),
            _row('Đã cọc', Formatters.formatCurrency(detail.depositAmount)),
          ],

          if (isFullyPaid && extraPaidAmount > 0) ...[
            const SizedBox(height: AppSpacing.sm),
            _row('Đã thanh toán', Formatters.formatCurrency(extraPaidAmount)),
          ],

          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Divider(height: 1, color: AppColors.surface),
          ),

          _row(
            'Cần thanh toán',
            Formatters.formatCurrency(detail.remainingAmount),
            valueColor: isFullyPaid ? AppColors.success : AppColors.primary,
            bold: true,
          ),
        ],
      ),
    );
  }
}
