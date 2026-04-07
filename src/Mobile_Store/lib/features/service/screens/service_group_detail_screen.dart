import 'package:flutter/material.dart';
import 'package:mobile_store/shared/widgets/inputs/app_filter_dropdown.dart';
import 'package:mobile_store/shared/widgets/inputs/app_header.dart'; 
import 'package:mobile_store/shared/widgets/feedback/snackbar_helper.dart'; 
import '../services/service_api.dart';
import '../models/service_group_model.dart';
import '../models/service_model.dart';
import '../../../shared/widgets/buttons/app_buttons.dart'; 
import '../widgets/service_bottom_sheet.dart';
import '../widgets/service_detail_card.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

enum ServiceDetailFilter { all, active, inactive }

class ServiceGroupDetailScreen extends StatefulWidget {
  final int storeId;
  final ServiceGroupModel group; 
  const ServiceGroupDetailScreen({super.key, required this.storeId, required this.group});

  @override
  State<ServiceGroupDetailScreen> createState() => _ServiceGroupDetailScreenState();
}

class _ServiceGroupDetailScreenState extends State<ServiceGroupDetailScreen> {
  bool _isLoading = true;
  List<ServiceModel> _services = []; 
  
  ServiceDetailFilter _currentFilter = ServiceDetailFilter.all;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() => _isLoading = true);
    try {
      final groups = await ServiceApi.getGroupedServices(widget.storeId);
      final currentGroup = groups.firstWhere(
        (g) => g.id == widget.group.id,
        orElse: () => ServiceGroupModel(id: widget.group.id, name: widget.group.name, services: [], storeId: widget.storeId, sortOrder: widget.group.sortOrder),
      );
      if (mounted) {
        setState(() {
          _services = currentGroup.services;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        SnackBarHelper.showError(context, 'Không thể tải danh sách dịch vụ.');
      }
    }
  }

  void _openServiceBottomSheet({ServiceModel? service}) {
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
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: ServiceBottomSheet(
              storeId: widget.storeId,
              service: service,
              serviceGroupId: widget.group.id,
              groupName: widget.group.name,
              onSuccess: _loadServices,
            ),
          ),
        ),
      ),
    );
  }
  void _confirmDeleteService(ServiceModel service) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMedium)),
        title: Text('Xác nhận xóa', style: AppTextStyles.heading1.copyWith(fontSize: 18, color: AppColors.error)),
        content: Text('Bạn có chắc muốn xóa dịch vụ "${service.name}" không?', style: AppTextStyles.bodyText),
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
                      await ServiceApi.deleteService(service.id);
                      if (!mounted) return;
                      SnackBarHelper.showSuccess(context, 'Đã xóa dịch vụ!');
                      _loadServices();
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
    final List<ServiceModel> filteredServices = _services.where((service) {
      if (_currentFilter == ServiceDetailFilter.active) return service.isActive;
      if (_currentFilter == ServiceDetailFilter.inactive) return !service.isActive;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(title: widget.group.name), 
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.paddingMedium, 
              vertical: AppDimens.paddingSmall
            ),
            color: AppColors.white,
            child: AppFilterDropdown<ServiceDetailFilter>(
              inlineLabel: 'Trạng thái: ',
              hint: 'Chọn trạng thái',
              value: _currentFilter,
              items: [
                DropdownMenuItem(value: ServiceDetailFilter.all, child: Text('Tất cả', style: AppTextStyles.bodyText)),
                DropdownMenuItem(value: ServiceDetailFilter.active, child: Text('Đang hiển thị', style: AppTextStyles.bodyText)),
                DropdownMenuItem(value: ServiceDetailFilter.inactive, child: Text('Đã ẩn', style: AppTextStyles.bodyText)),
              ],
              onChanged: (ServiceDetailFilter? filter) {
                if (filter != null && filter != _currentFilter) {
                  setState(() => _currentFilter = filter);
                }
              },
            ),
          ),
          
          Expanded(
            child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary)) 
              : filteredServices.isEmpty 
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      color: AppColors.primary, 
                      onRefresh: _loadServices,
                      child: ListView.separated(
                        padding: const EdgeInsets.only(
                          top: AppDimens.paddingMedium, 
                          left: AppDimens.paddingMedium, 
                          right: AppDimens.paddingMedium, 
                          bottom: 80 
                        ),
                        itemCount: filteredServices.length, 
                        separatorBuilder: (context, index) => const SizedBox(height: AppDimens.paddingSmall),
                        itemBuilder: (context, index) => ServiceDetailCard(
                          service: filteredServices[index], 
                          onEdit: () => _openServiceBottomSheet(service: filteredServices[index]), 
                          onDelete: () => _confirmDeleteService(filteredServices[index]), 
                        ),
                      ),
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary, 
        onPressed: () => _openServiceBottomSheet(),
        icon: const Icon(Icons.add, color: AppColors.white),
        label: Text('Thêm dịch vụ', style: AppTextStyles.labelSmall.copyWith(color: AppColors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.spa_outlined, size: 80, color: AppColors.error.withValues(alpha: 0.5)), 
          const SizedBox(height: AppDimens.paddingMedium),
          Text(
            _currentFilter != ServiceDetailFilter.all && _services.isNotEmpty 
                ? 'Không có dịch vụ nào phù hợp với bộ lọc' 
                : 'Nhóm này chưa có dịch vụ nào', 
            style: AppTextStyles.bodyText.copyWith(color: AppColors.textSub)
          ),
        ],
      ),
    );
  }
}