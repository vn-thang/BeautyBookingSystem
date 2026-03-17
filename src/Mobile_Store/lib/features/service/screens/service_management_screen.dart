import 'package:flutter/material.dart';
import '../models/service_group_model.dart';
import '../models/service_model.dart';
import '../services/service_api.dart';
import '../../../shared/widgets/shared_service_widgets.dart';
import '../widgets/service_group_bottom_sheet.dart';
import '../widgets/service_bottom_sheet.dart';
import '../widgets/service_group_card.dart';
import '../widgets/free_service_tile.dart';
import 'service_group_detail_screen.dart';
import '../../../core/theme/app_colors.dart';

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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => ServiceBottomSheet(
        storeId: widget.storeId,
        service: service,
        serviceGroupId: 0,
        groupName: "Dịch vụ tự do",
        onSuccess: _loadData,
      ),
    );
  }

  void _confirmDeleteGroup(ServiceGroupModel group) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa nhóm "${group.name}" không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
          TextButton(
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
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100, 
      appBar: AppBar(
        title: const Text('Quản lý dịch vụ', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(10.0),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.primary),
            ),
          ),
        ),
        actions: [
          PopupMenuButton<ServiceFilter>(
            icon: const Icon(Icons.filter_list_rounded, color: AppColors.background),
            tooltip: 'Lọc dịch vụ',
            onSelected: (ServiceFilter filter) {
              if (_currentFilter != filter) {
                setState(() => _currentFilter = filter);
              }
            },
            itemBuilder: (context) => [
              CheckedPopupMenuItem<ServiceFilter>(
                value: ServiceFilter.all,
                checked: _currentFilter == ServiceFilter.all,
                child: const Text('Tất cả'),
              ),
              CheckedPopupMenuItem<ServiceFilter>(
                value: ServiceFilter.active,
                checked: _currentFilter == ServiceFilter.active,
                child: const Text('Đang hiển thị'),
              ),
              CheckedPopupMenuItem<ServiceFilter>(
                value: ServiceFilter.inactive,
                checked: _currentFilter == ServiceFilter.inactive,
                child: const Text('Đã ẩn'),
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder<List<ServiceGroupModel>>(
        future: _groupedServicesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          if (snapshot.hasError) return Center(child: Text("Lỗi: ${snapshot.error}"));
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("Chưa có dữ liệu."));

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
          }).where((group) => group.id == 0 || group.services.isNotEmpty).toList();
          
          final ungroupedGroup = groups.firstWhere(
            (g) => g.id == 0,
            orElse: () => ServiceGroupModel(id: 0, name: '', services: [], storeId: widget.storeId, sortOrder: 0), 
          );
          final realGroups = groups.where((g) => g.id != 0).toList();

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async => _loadData(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (ungroupedGroup.services.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12, left: 4),
                    child: Text("Dịch vụ tự do", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                  ),
                  ...ungroupedGroup.services.map((service) => FreeServiceTile(
                    service: service,
                    onTap: () => _openFreeServiceBottomSheet(service: service),
                  )),
                  const SizedBox(height: 24),
                ],
                if (realGroups.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12, left: 4),
                    child: Text("Nhóm dịch vụ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                  ),
                  ...realGroups.map((group) => ServiceGroupCard(
                    group: group,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ServiceGroupDetailScreen(storeId: widget.storeId, group: group))).then((_) => _loadData()),
                    onEdit: () => _openGroupBottomSheet(group: group),
                    onDelete: () => _confirmDeleteGroup(group),
                  )),
                ],
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _openGroupBottomSheet(),
                  child: const Text('Thêm Nhóm', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: () => _openFreeServiceBottomSheet(),
                  child: const Text('Thêm Dịch Vụ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}