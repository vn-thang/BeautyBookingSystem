import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/inputs/app_filter_dropdown.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';

class StoreSettingsSection extends StatelessWidget {
  final bool isOpen;
  final ValueChanged<bool> onToggleOpen;
  final int depositPercent;
  final List<int> depositOptions;
  final ValueChanged<int?> onDepositPercentChanged;
  final TextEditingController depositThresholdController;
  final TextEditingController descController;
  final Color primaryColor;

  const StoreSettingsSection({
    super.key,
    required this.isOpen,
    required this.onToggleOpen,
    required this.depositPercent,
    required this.depositOptions,
    required this.onDepositPercentChanged,
    required this.depositThresholdController,
    required this.descController,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.meeting_room_outlined, color: primaryColor),
          title: Text(
            "Đóng cửa/Mở cửa",
            style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          trailing: Transform.scale(
            scale: 0.8,
            child: Switch(
              activeThumbColor: AppColors.white,
              activeTrackColor: AppColors.success,
              inactiveThumbColor: AppColors.white,
              inactiveTrackColor: AppColors.textSub.withValues(alpha: 0.3),
              trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
              value: isOpen,
              onChanged: onToggleOpen,
            ),
          ),
        ),
        const Divider(height: 1, thickness: 1, color: AppColors.surface),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.percent_outlined, color: primaryColor),
          title: Text("Yêu cầu khách cọc trước", style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.w600, fontSize: 15)),
          trailing: SizedBox(
            width: 140,
            child: AppFilterDropdown<int>(
              hint: "",
              value: depositPercent,
              items: depositOptions.map((int value) => DropdownMenuItem<int>(
                value: value,
                child: Text(
                  value == 0 ? "Cọc 0%" : "Cọc $value%",
                  style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.w500),
                ),
              )).toList(),
              onChanged: onDepositPercentChanged,
            ),
          ),
        ),
        const Divider(height: 1, thickness: 1, color: AppColors.surface),
        const SizedBox(height: 12),
        AppTextField(
          controller: depositThresholdController,
          label: 'Đơn tối thiểu bắt buộc cọc (VNĐ)',
          hint: 'VD: 200000 (Nhập 0 để cọc mọi đơn)',
          icon: Icons.price_check_outlined,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 20),
        Row(children: [
          Icon(Icons.description_outlined, color: primaryColor),
          const SizedBox(width: 15),
          Text("Giới thiệu cửa hàng", style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.w600, fontSize: 15))
        ]),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.surface, width: 1.5),
            borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusMedium)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Normal", style: AppTextStyles.labelSmall), const Icon(Icons.arrow_drop_down, color: AppColors.textSub),
                    Text("Sans Serif", style: AppTextStyles.labelSmall), const Icon(Icons.arrow_drop_down, color: AppColors.textSub),
                    Text("12 pt", style: AppTextStyles.labelSmall),
                  ],
                ),
              ),
              TextFormField(
                controller: descController,
                maxLines: 4,
                style: AppTextStyles.bodyText,
                decoration: InputDecoration(
                  hintText: "Nhập mô tả...",
                  hintStyle: AppTextStyles.labelSmall,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}