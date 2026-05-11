import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/store_booking_model.dart'; 

class Step3StaffWidget extends StatelessWidget {
  final bool isLoadingStaffs;
  final List<AvailableStaffModel> availableStaffs;
  final int? selectedStaffId;
  final Function(int?) onStaffSelected;

  const Step3StaffWidget({
    super.key,
    required this.isLoadingStaffs,
    required this.availableStaffs,
    required this.selectedStaffId,
    required this.onStaffSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoadingStaffs) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (availableStaffs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off_outlined, size: 64, color: AppColors.textSub.withValues(alpha: 0.5)),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Không có nhân viên rảnh\nvào khung giờ này',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyText.copyWith(color: AppColors.textSub),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppDimens.paddingMedium),
      children: [
        Text('Chọn nhân viên phục vụ', style: AppTextStyles.heading1.copyWith(fontSize: 18)),
        const SizedBox(height: AppSpacing.xs),

        const Divider(),
        const SizedBox(height: AppSpacing.md),

        ...availableStaffs.map((staff) {
          final isSelected = selectedStaffId == staff.id;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _buildStaffCard(
              id: staff.id,
              name: staff.fullName,
              subtitle: 'Chuyên viên',
              avatarUrl: staff.avatarUrl,
              isSelected: isSelected,
              isAny: false,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStaffCard({
    required int? id,
    required String name,
    required String subtitle,
    required String? avatarUrl,
    required bool isSelected,
    required bool isAny,
  }) {
    return InkWell(
      onTap: () => onStaffSelected(id),
      borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
      child: Container(
        padding: const EdgeInsets.all(AppDimens.paddingMedium),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.05) : AppColors.white,
          borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.surface,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [] 
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: Row(
          children: [
            // Khối Avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isAny ? AppColors.surface : AppColors.primary.withValues(alpha: 0.1),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.transparent, 
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: isAny
                    ? const Icon(Icons.group_outlined, color: AppColors.textSub)
                    : (avatarUrl != null && avatarUrl.isNotEmpty)
                        ? Image.network(
                            avatarUrl, 
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _buildFallbackAvatar(name),
                          )
                        : _buildFallbackAvatar(name),
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.bodyText.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.primary : AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSub),
                  ),
                ],
              ),
            ),

            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.textSub.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: AppColors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackAvatar(String name) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: AppTextStyles.heading1.copyWith(fontSize: 20, color: AppColors.primary),
      ),
    );
  }
}