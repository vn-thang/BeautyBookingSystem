
// import 'package:flutter/material.dart';
// import '../services/service_api.dart';
// import '../models/service_group_model.dart';
// import '../models/service_model.dart';
// import '../../../shared/widgets/shared_service_widgets.dart';
// import '../widgets/service_bottom_sheet.dart';
// import '../widgets/service_detail_card.dart';
// import '../../../core/theme/app_colors.dart';


// class ServiceGroupDetailScreen extends StatefulWidget {
//   final int storeId;
//   final ServiceGroupModel group; 
//   const ServiceGroupDetailScreen({super.key, required this.storeId, required this.group});

//   @override
//   State<ServiceGroupDetailScreen> createState() => _ServiceGroupDetailScreenState();
// }

// class _ServiceGroupDetailScreenState extends State<ServiceGroupDetailScreen> {
//   bool _isLoading = true;
//   List<ServiceModel> _services = []; 

//   @override
//   void initState() {
//     super.initState();
//     _loadServices();
//   }

//   Future<void> _loadServices() async {
//     setState(() => _isLoading = true);
//     try {
//       final groups = await ServiceApi.getGroupedServices(widget.storeId);
//       final currentGroup = groups.firstWhere(
//         (g) => g.id == widget.group.id,
//         orElse: () => ServiceGroupModel(id: widget.group.id, name: widget.group.name, services: [], storeId: widget.storeId, sortOrder: widget.group.sortOrder),
//       );
//       if (mounted) {
//         setState(() {
//           _services = currentGroup.services;
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() => _isLoading = false);
//         SnackBarHelper.showError(context, 'Không thể tải danh sách dịch vụ.');
//       }
//     }
//   }

//   // Mở BottomSheet Thêm/Sửa Dịch vụ
//   void _openServiceBottomSheet({ServiceModel? service}) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
//       builder: (context) => ServiceBottomSheet(
//         storeId: widget.storeId,
//         service: service,
//         serviceGroupId: widget.group.id,
//         groupName: widget.group.name,
//         onSuccess: _loadServices,
//       ),
//     );
//   }

//   void _confirmDeleteService(ServiceModel service) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text('Xác nhận xóa'),
//         content: Text('Bạn có chắc muốn xóa dịch vụ "${service.name}" không?'),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
//           TextButton(
//             onPressed: () async {
//               Navigator.pop(ctx);
//               try {
//                 await ServiceApi.deleteService(service.id);
//                 if (!mounted) return;
//                 SnackBarHelper.showSuccess(context, 'Đã xóa dịch vụ!');
//                 _loadServices();
//                 } catch (e) {
//                 if (!mounted) return;
//                 SnackBarHelper.showError(context, e.toString());
//               }
//             },
//             child: const Text('Xóa', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade50,
//       appBar: AppBar(
//         backgroundColor: AppColors.primary, // Đã chuyển sang nền đỏ
//         elevation: 0,
//         centerTitle: true,
//         iconTheme: const IconThemeData(color: Colors.white), // Chuyển icon sang trắng để tương phản với nền đỏ
//         title: Text(widget.group.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), // Chữ tiêu đề màu trắng
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator(color: AppColors.primary)) // Chuyển sang màu đỏ
//           : _services.isEmpty
//               ? _buildEmptyState()
//               : RefreshIndicator(
//                   color: AppColors.primary, // Chuyển sang màu đỏ
//                   onRefresh: _loadServices,
//                   child: ListView.separated(
//                     padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 80),
//                     itemCount: _services.length,
//                     separatorBuilder: (context, index) => const SizedBox(height: 12),
//                     itemBuilder: (context, index) => ServiceDetailCard(
//                       service: _services[index],
//                       onEdit: () => _openServiceBottomSheet(service: _services[index]),
//                       onDelete: () => _confirmDeleteService(_services[index]),
//                     ),
//                   ),
//                 ),
//       floatingActionButton: FloatingActionButton.extended(
//         backgroundColor: AppColors.primary, // Chuyển nút thêm thành màu đỏ
//         onPressed: () => _openServiceBottomSheet(),
//         icon: const Icon(Icons.add, color: Colors.white),
//         label: const Text('Thêm dịch vụ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.spa_outlined, size: 80, color: Colors.red.shade200), // Chuyển icon trống sang tone đỏ nhạt
//           const SizedBox(height: 16),
//           Text('Nhóm này chưa có dịch vụ nào', style: TextStyle(fontSize: 16, color: Colors.grey.shade500)),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import '../services/service_api.dart';
import '../models/service_group_model.dart';
import '../models/service_model.dart';
import '../../../shared/widgets/shared_service_widgets.dart';
import '../widgets/service_bottom_sheet.dart';
import '../widgets/service_detail_card.dart';
import '../../../core/theme/app_colors.dart';

// THÊM: Enum quản lý trạng thái lọc (đặt tên khác một chút để tránh trùng lặp với file quản lý nhóm)
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
  
  // THÊM: Biến lưu trạng thái lọc hiện tại
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

  // Mở BottomSheet Thêm/Sửa Dịch vụ
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
    // THÊM: Logic lọc dữ liệu trước khi render
    final List<ServiceModel> filteredServices = _services.where((service) {
      if (_currentFilter == ServiceDetailFilter.active) return service.isActive;
      if (_currentFilter == ServiceDetailFilter.inactive) return !service.isActive;
      return true; // Trường hợp All
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: AppColors.primary, 
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white), 
        title: Text(widget.group.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), 
        // THÊM: Nút lọc trên AppBar
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
          : filteredServices.isEmpty // SỬA: Đổi từ _services.isEmpty sang filteredServices.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  color: AppColors.primary, 
                  onRefresh: _loadServices,
                  child: ListView.separated(
                    padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 80),
                    itemCount: filteredServices.length, // SỬA: Dùng filteredServices
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => ServiceDetailCard(
                      service: filteredServices[index], // SỬA: Dùng filteredServices
                      onEdit: () => _openServiceBottomSheet(service: filteredServices[index]), // SỬA
                      onDelete: () => _confirmDeleteService(filteredServices[index]), // SỬA
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
          // Thêm logic nhỏ để hiển thị text phù hợp nếu đang lọc
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