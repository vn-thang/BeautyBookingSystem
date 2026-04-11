import 'package:flutter/material.dart';
import '../../../shared/widgets/feedback/app_error_box.dart';
import '../../../shared/widgets/inputs/app_filter_dropdown.dart';
import '../../../shared/widgets/inputs/app_header.dart';
import '../../../shared/widgets/feedback/snackbar_helper.dart'; 
import '../../../shared/widgets/buttons/app_buttons.dart'; 
import '../../../shared/models/service_group_model.dart';
import '../../../shared/models/service_model.dart';
import '../services/service_api.dart';
import '../widgets/service_group_bottom_sheet.dart';
import '../widgets/service_bottom_sheet.dart';
import '../widgets/service_group_card.dart';
import '../widgets/free_service_tile.dart';
import 'service_group_detail_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

enum ServiceFilter { all, active, inactive }

class ServiceManagementScreen extends StatefulWidget {
  final int storeId;
  const ServiceManagementScreen({super.key, required this.storeId});

  @override
  State<ServiceManagementScreen> createState() => _ServiceManagementScreenState();
}

class _ServiceManagementScreenState extends State<ServiceManagementScreen> {
  late Future<List<ServiceGroupModel>> _groupedServicesFuture;
  
  ServiceFilter _currentFilter = ServiceFilter.all;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _groupedServicesFuture = ServiceApi.getGroupedServices(widget.storeId);
    });
  }

  void _openGroupBottomSheet({ServiceGroupModel? group}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusLarge))
      ),
      builder: (context) => ServiceGroupBottomSheet(
        storeId: widget.storeId,
        group: group,
        onSuccess: _loadData,
      ),
    );
  }

  void _openFreeServiceBottomSheet({ServiceModel? service}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.91, 
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusLarge)),
          ),
          child: ServiceBottomSheet(
            storeId: widget.storeId,
            service: service,
            serviceGroupId: 0,
            groupName: "Dịch vụ tự do",
            onSuccess: _loadData,
          ),
        ),
      ),
    );
  }

  void _confirmDeleteGroup(ServiceGroupModel group) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMedium)),
        title: Text('Xác nhận xóa', style: AppTextStyles.heading1.copyWith(fontSize: 18, color: AppColors.error)),
        content: Text('Bạn có chắc muốn xóa nhóm "${group.name}" không?', style: AppTextStyles.bodyText),
        actions: [
          Row(
            children: [
              Expanded(
                child: AppOutlineButton(
                  text: 'HỦY', 
                  color: AppColors.textSub,
                  onTap: () => Navigator.pop(ctx)
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppPrimaryButton(
                  text: 'XÓA',
                  color: AppColors.error, 
                  onPressed: () async {
                    Navigator.pop(ctx);
                    try {
                      await ServiceApi.deleteServiceGroup(group.id);
                      if (!mounted) return;
                      SnackBarHelper.showSuccess(context, 'Đã xóa nhóm!');
                      _loadData();
                    } catch (e) {
                      if (!mounted) return;
                      SnackBarHelper.showError(context, e.toString());
                    }
                  },
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, 
      appBar: const AppHeader(
        title: 'Quản lý dịch vụ',
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.paddingMedium, 
              vertical: AppDimens.paddingSmall
            ),
            color: AppColors.white,
            child: AppFilterDropdown<ServiceFilter>(
              inlineLabel: 'Trạng thái: ',
              hint: 'Chọn trạng thái',
              value: _currentFilter,
              items: [
                DropdownMenuItem(
                  value: ServiceFilter.all, 
                  child: Text('Tất cả', style: AppTextStyles.bodyText)
                ),
                DropdownMenuItem(
                  value: ServiceFilter.active, 
                  child: Text('Đang hiển thị', style: AppTextStyles.bodyText)
                ),
                DropdownMenuItem(
                  value: ServiceFilter.inactive, 
                  child: Text('Đã ẩn', style: AppTextStyles.bodyText)
                ),
              ],
              onChanged: (ServiceFilter? filter) {
                if (filter != null && filter != _currentFilter) {
                  setState(() => _currentFilter = filter);
                }
              },
            ),
          ),
          
          Expanded(
            child: FutureBuilder<List<ServiceGroupModel>>(
              future: _groupedServicesFuture,
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
                  return Center(child: Text("Chưa có dữ liệu.", style: AppTextStyles.bodyText));
                }

                final allGroups = snapshot.data!;
                final groups = allGroups.map((group) {
                  final filteredServices = group.services.where((service) {
                    if (_currentFilter == ServiceFilter.active) return service.isActive;
                    if (_currentFilter == ServiceFilter.inactive) return !service.isActive;
                    return true; 
                  }).toList();

                  return ServiceGroupModel(
                    id: group.id,
                    name: group.name,
                    storeId: group.storeId,
                    sortOrder: group.sortOrder,
                    services: filteredServices,
                  );
                }).toList();
                
                final ungroupedGroup = groups.firstWhere(
                  (g) => g.id == 0,
                  orElse: () => ServiceGroupModel(id: 0, name: '', services: [], storeId: widget.storeId, sortOrder: 0), 
                );
                final realGroups = groups.where((g) => g.id != 0).toList();

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async => _loadData(),
                  child: ListView(
                    padding: const EdgeInsets.all(AppDimens.paddingMedium),
                    children: [
                      if (ungroupedGroup.services.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md, left: AppSpacing.xs),
                          child: Text("Dịch vụ tự do", style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                        ...ungroupedGroup.services.map((service) => FreeServiceTile(
                          service: service,
                          onTap: () => _openFreeServiceBottomSheet(service: service),
                        )),
                        const SizedBox(height: AppDimens.paddingLarge),
                      ],
                      if (realGroups.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md, left: AppSpacing.xs),
                          child: Text("Nhóm dịch vụ", style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                        ...realGroups.map((group) => ServiceGroupCard(
                          group: group,
                          onTap: () => Navigator.push(context, MaterialPageRoute(
                            builder: (context) => ServiceGroupDetailScreen(storeId: widget.storeId, group: group)
                          )).then((_) => _loadData()),
                          onEdit: () => _openGroupBottomSheet(group: group),
                          onDelete: () => _confirmDeleteGroup(group),
                        )),
                      ],
                    ],
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
          child: Row(
            children: [
              Expanded(
                child: AppOutlineButton(
                  text: 'Thêm Nhóm',
                  onTap: () => _openGroupBottomSheet(),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppPrimaryButton(
                  text: 'Thêm Dịch Vụ',
                  onPressed: () => _openFreeServiceBottomSheet(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}