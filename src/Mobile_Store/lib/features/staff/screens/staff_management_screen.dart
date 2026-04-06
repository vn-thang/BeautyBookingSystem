import 'package:flutter/material.dart';
import 'package:mobile_store/shared/widgets/buttons/app_buttons.dart';
import 'package:mobile_store/shared/widgets/feedback/snackbar_helper.dart';
import '../models/staff_model.dart';
import '../services/staff_api.dart';
import '../widgets/staff_tile.dart';
import '../widgets/staff_form_bottom_sheet.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/inputs/app_header.dart';
import '../../../shared/widgets/inputs/app_filter_dropdown.dart';
import '../../../shared/widgets/feedback/app_error_box.dart';

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  late Future<List<StaffModel>> _staffsFuture;
  bool _showOnlyActive = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _staffsFuture = StaffApi.getStaffs(onlyActive: _showOnlyActive);
    });
  }

void _openFormBottomSheet({StaffModel? staff}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, 
      builder: (context) => Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20), 
        child: StaffFormBottomSheet(
          staff: staff,
          onSuccess: _loadData,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(StaffModel staff) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusLarge)),
        title: Text('Xác nhận ẩn', style: AppTextStyles.heading1.copyWith(fontSize: 20)),
        content: Text('Bạn có chắc chắn muốn ẩn nhân viên "${staff.fullName}" không?', style: AppTextStyles.bodyText),
        actions: [
          Row(
            children: [
              Expanded(
                child: AppOutlineButton(
                  text: 'HỦY', 
                  color: AppColors.textSub,
                  onTap: () => Navigator.pop(context, false)
                )
              ),
              const SizedBox(width: AppDimens.paddingSmall),
              Expanded(
                child: AppPrimaryButton(
                  text: 'ẨN',
                  color: AppColors.error, 
                  onPressed: () => Navigator.pop(context, true),
                )
              ),
            ],
          )
        ],
      ),
    );

    if (confirm == true) {
      try {
        await StaffApi.deleteStaff(staff.id);
        _loadData();
        if (!mounted) return;
        SnackBarHelper.showSuccess(context, 'Đã ẩn nhân viên');
      } catch (e) {
        if (!mounted) return;
        SnackBarHelper.showError(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(
        title: 'Quản lý Nhân viên',
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.paddingMedium, 
              vertical: AppDimens.paddingSmall
            ),
            color: AppColors.white,
            child: AppFilterDropdown<bool>(
              inlineLabel: 'Trạng thái: ',
              hint: 'Chọn trạng thái',
              value: _showOnlyActive,
              items: [
                DropdownMenuItem(
                  value: true, 
                  child: Text('Đang hoạt động', style: AppTextStyles.bodyText)
                ),
                DropdownMenuItem(
                  value: false, 
                  child: Text('Tất cả (Gồm đã ẩn)', style: AppTextStyles.bodyText)
                ),
              ],
              onChanged: (bool? value) {
                if (value != null && value != _showOnlyActive) {
                  setState(() => _showOnlyActive = value);
                  _loadData();
                }
              },
            ),
          ),

          Expanded(
            child: FutureBuilder<List<StaffModel>>(
              future: _staffsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                } 
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(AppDimens.paddingMedium),
                    child: Center(child: AppErrorBox(errorMessage: snapshot.error.toString())),
                  );
                } 
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState();
                }

                final staffs = snapshot.data!;
                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async => _loadData(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppDimens.paddingMedium),
                    itemCount: staffs.length,
                    itemBuilder: (context, index) {
                      final staff = staffs[index];
                      return StaffTile(
                        staff: staff,
                        onEdit: () => _openFormBottomSheet(staff: staff),
                        onDelete: () => _confirmDelete(staff),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingMedium, vertical: AppDimens.paddingSmall),
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.textMain.withValues(alpha: 0.05), 
                blurRadius: 10, 
                offset: const Offset(0, -5)
              )
            ],
          ),
          child: AppPrimaryButton(
            text: 'Thêm Nhân Viên',
            onPressed: () => _openFormBottomSheet(),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_alt_outlined, size: 80, color: AppColors.textSub.withValues(alpha: 0.3)),
          const SizedBox(height: AppDimens.paddingMedium),
          Text(
            _showOnlyActive ? 'Chưa có nhân viên nào đang làm.' : 'Chưa có nhân viên nào.',
            style: AppTextStyles.bodyText.copyWith(color: AppColors.textSub),
          ),
        ],
      ),
    );
  }
}