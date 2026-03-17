import 'package:flutter/material.dart';
import '../services/service_api.dart';
import '../models/service_group_model.dart';
import '../models/service_model.dart';
import '../../../shared/widgets/shared_service_widgets.dart';
import '../widgets/service_bottom_sheet.dart';
import '../widgets/service_detail_card.dart';
import '../../../core/theme/app_colors.dart';

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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => ServiceBottomSheet(
        storeId: widget.storeId,
        service: service,
        serviceGroupId: widget.group.id,
        groupName: widget.group.name,
        onSuccess: _loadServices,
      ),
    );
  }

  void _confirmDeleteService(ServiceModel service) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa dịch vụ "${service.name}" không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
          TextButton(
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
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: AppColors.primary, 
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white), 
        title: Text(widget.group.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), 
        
        actions: [
          PopupMenuButton<ServiceDetailFilter>(
            icon: const Icon(Icons.filter_list_rounded, color: Colors.white),
            tooltip: 'Lọc dịch vụ',
            onSelected: (ServiceDetailFilter filter) {
              if (_currentFilter != filter) {
                setState(() => _currentFilter = filter);
              }
            },
            itemBuilder: (context) => [
              CheckedPopupMenuItem<ServiceDetailFilter>(
                value: ServiceDetailFilter.all,
                checked: _currentFilter == ServiceDetailFilter.all,
                child: const Text('Tất cả'),
              ),
              CheckedPopupMenuItem<ServiceDetailFilter>(
                value: ServiceDetailFilter.active,
                checked: _currentFilter == ServiceDetailFilter.active,
                child: const Text('Đang hiển thị'),
              ),
              CheckedPopupMenuItem<ServiceDetailFilter>(
                value: ServiceDetailFilter.inactive,
                checked: _currentFilter == ServiceDetailFilter.inactive,
                child: const Text('Đã ẩn'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary)) 
          : filteredServices.isEmpty 
              ? _buildEmptyState()
              : RefreshIndicator(
                  color: AppColors.primary, 
                  onRefresh: _loadServices,
                  child: ListView.separated(
                    padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 80),
                    itemCount: filteredServices.length, 
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => ServiceDetailCard(
                      service: filteredServices[index], 
                      onEdit: () => _openServiceBottomSheet(service: filteredServices[index]), 
                      onDelete: () => _confirmDeleteService(filteredServices[index]), 
                    ),
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary, 
        onPressed: () => _openServiceBottomSheet(),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Thêm dịch vụ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.spa_outlined, size: 80, color: Colors.red.shade200), 
          const SizedBox(height: 16),
          Text(
            _currentFilter != ServiceDetailFilter.all && _services.isNotEmpty 
                ? 'Không có dịch vụ nào phù hợp với bộ lọc' 
                : 'Nhóm này chưa có dịch vụ nào', 
            style: TextStyle(fontSize: 16, color: Colors.grey.shade500)
          ),
        ],
      ),
    );
  }
}