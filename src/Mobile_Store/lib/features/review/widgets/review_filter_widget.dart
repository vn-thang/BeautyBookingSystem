import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../shared/widgets/inputs/app_filter_dropdown.dart'; // Đảm bảo đúng path tới AppFilterDropdown

class ReviewFilterWidget extends StatelessWidget {
  final int? selectedRating;
  final bool? selectedHasReplied;
  final Function(int? rating, bool? hasReplied) onFilterChanged;

  const ReviewFilterWidget({
    super.key,
    required this.selectedRating,
    required this.selectedHasReplied,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingMedium, vertical: AppDimens.paddingSmall),
      color: AppColors.white,
      child: Row(
        children: [
          Expanded(
            child: AppFilterDropdown<int?>(
              hint: 'Số sao',
              value: selectedRating,
              items: [
                DropdownMenuItem(value: null, child: Text('Tất cả sao', style: AppTextStyles.bodyText)),
                DropdownMenuItem(value: 5, child: Text('5 Sao ⭐', style: AppTextStyles.bodyText)),
                DropdownMenuItem(value: 4, child: Text('4 Sao ⭐', style: AppTextStyles.bodyText)),
                DropdownMenuItem(value: 3, child: Text('3 Sao ⭐', style: AppTextStyles.bodyText)),
                DropdownMenuItem(value: 2, child: Text('2 Sao ⭐', style: AppTextStyles.bodyText)),
                DropdownMenuItem(value: 1, child: Text('1 Sao ⭐', style: AppTextStyles.bodyText)),
              ],
              onChanged: (val) => onFilterChanged(val, selectedHasReplied),
            ),
          ),
          const SizedBox(width: AppDimens.paddingSmall),
          Expanded(
            child: AppFilterDropdown<bool?>(
              hint: 'Trạng thái',
              value: selectedHasReplied,
              items: [
                DropdownMenuItem(value: null, child: Text('Tất cả', style: AppTextStyles.bodyText)),
                DropdownMenuItem(value: false, child: Text('Chưa trả lời', style: AppTextStyles.bodyText)),
                DropdownMenuItem(value: true, child: Text('Đã trả lời', style: AppTextStyles.bodyText)),
              ],
              onChanged: (val) => onFilterChanged(selectedRating, val),
            ),
          ),
        ],
      ),
    );
  }
}