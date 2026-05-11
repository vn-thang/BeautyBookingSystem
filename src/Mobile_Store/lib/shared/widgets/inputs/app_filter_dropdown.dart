import 'package:flutter/material.dart';
import 'package:mobile_store/core/theme/app_dimens.dart';
import 'package:mobile_store/core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart'; 

class AppFilterDropdown<T> extends StatelessWidget {
  final String? inlineLabel; 
  final String hint;         
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?) onChanged;
  final bool isLoading;
  final double height;
  final DropdownButtonBuilder? selectedItemBuilder;
  final AlignmentGeometry alignment;
  final double? menuWidth;

  const AppFilterDropdown({
    super.key,
    this.inlineLabel,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.isLoading = false,
    this.height = 36, 
    this.selectedItemBuilder,
    this.alignment = Alignment.centerLeft,
    this.menuWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (inlineLabel != null && inlineLabel!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text(
              inlineLabel!,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
        Expanded(
          child: Container(
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.white, 
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
              borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
            ),
            child: isLoading
                ? const Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : DropdownButtonHideUnderline(
                    child: DropdownButton<T>(
                      value: value,
                      isExpanded: true,
                      isDense: true,
                      alignment: alignment,
                      menuWidth: menuWidth,
                      itemHeight: 50, 
                      menuMaxHeight: 400,
                      selectedItemBuilder: selectedItemBuilder,
                      focusColor: Colors.transparent, 
                      dropdownColor: AppColors.white,
                      icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                      hint: Text(
                        hint,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      items: items,
                      onChanged: onChanged,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}