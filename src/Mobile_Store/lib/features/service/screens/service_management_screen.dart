// import 'package:flutter/material.dart';

// // Đảm bảo import đầy đủ các file này
// import '../models/service_group_model.dart';
// import '../models/service_model.dart'; 
// import '../services/service_api.dart';
// import '../widgets/add_service_group_bottom_sheet.dart';
// import 'service_group_detail_screen.dart'; 
// import '../widgets/edit_service_group_bottom_sheet.dart';
// import '../widgets/add_service_bottom_sheet.dart';
// import '../widgets/edit_service_bottom_sheet.dart'; 

// class ServiceManagementScreen extends StatefulWidget {
//   final int storeId;

//   const ServiceManagementScreen({super.key, required this.storeId});

//   @override
//   State<ServiceManagementScreen> createState() => _ServiceManagementScreenState();
// }

// class _ServiceManagementScreenState extends State<ServiceManagementScreen> {
//   late Future<List<ServiceGroupModel>> _groupedServicesFuture;
  
//   final Color primaryColor = const Color(0xFFDE4660); 

//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }

//   void _loadData() {
//     setState(() {
//       _groupedServicesFuture = ServiceApi.getGroupedServices(widget.storeId);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade100, 
//       appBar: AppBar(
//         title: const Text('Quản lý dịch vụ', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
//         centerTitle: true,
//         backgroundColor: primaryColor,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         leading: Padding(
//           padding: const EdgeInsets.all(10.0),
//           child: InkWell(
//             onTap: () => Navigator.pop(context),
//             child: Container(
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(Icons.arrow_back_ios_new, size: 18, color: primaryColor),
//             ),
//           ),
//         ),
//       ),
      
//       body: FutureBuilder<List<ServiceGroupModel>>(
//         future: _groupedServicesFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator(color: primaryColor));
//           } 
//           else if (snapshot.hasError) {
//             return _buildErrorState(snapshot.error.toString());
//           } 
//           else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return _buildEmptyState();
//           }

//           final groups = snapshot.data!;
//           // LẤY DỊCH VỤ TỰ DO (An toàn hơn)
//           final ungroupedGroup = groups.firstWhere(
//             (g) => g.id == 0,
//             orElse: () => ServiceGroupModel(id: -1, name: '', services: [], storeId: widget.storeId, sortOrder: 0), 
//           );
//           final ungroupedServices = ungroupedGroup.services; 
          
//           // LẤY NHÓM THỰC SỰ
//           final realGroups = groups.where((g) => g.id != 0).toList();

//           return RefreshIndicator(
//             color: primaryColor,
//             onRefresh: () async => _loadData(),
//             child: ListView(
//               padding: const EdgeInsets.all(16),
//               children: [
//                 if (ungroupedServices.isNotEmpty) ...[
//                   const Padding(
//                     padding: EdgeInsets.only(bottom: 12, left: 4),
//                     child: Text("Dịch vụ tự do", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
//                   ),
//                   ...ungroupedServices.map((service) => _buildSimpleServiceTile(service)),
//                   const SizedBox(height: 24),
//                 ],

//                 if (realGroups.isNotEmpty) ...[
//                   const Padding(
//                     padding: EdgeInsets.only(bottom: 12, left: 4),
//                     child: Text("Nhóm dịch vụ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
//                   ),
//                   ...realGroups.map((group) => _buildGroupCard(group)),
//                 ],
//               ],
//             ),
//           );
//         },
//       ),

//       bottomNavigationBar: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Row(
//             children: [
//               Expanded(
//                 child: OutlinedButton(
//                   onPressed: _openAddServiceBottomSheet, 
//                   style: OutlinedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     side: BorderSide(color: primaryColor, width: 1.5),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                   ),
//                   child: Text('Thêm dịch vụ', style: TextStyle(color: primaryColor, fontSize: 16, fontWeight: FontWeight.w600)),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: _showAddGroupBottomSheet,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: primaryColor,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                     elevation: 0,
//                   ),
//                   child: const Text('Thêm nhóm', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _openAddServiceBottomSheet() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
//       builder: (context) => AddServiceBottomSheet(
//         storeId: widget.storeId, 
//         serviceGroupId: null,      
//         groupName: "Dịch vụ tự do",
//         onSuccess: _loadData,
//       ),
//     );
//   }

//   void _showAddGroupBottomSheet() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent, 
//       builder: (context) => Container(
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         child: AddServiceGroupBottomSheet(
//           storeId: widget.storeId,
//           onSuccess: _loadData,
//         ),
//       ),
//     );
//   }

//   void _openEditGroupBottomSheet(ServiceGroupModel group) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent, 
//       builder: (context) => Container(
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         child: EditServiceGroupBottomSheet(
//           storeId: widget.storeId,
//           group: group,
//           onSuccess: _loadData, 
//         ),
//       ),
//     );
//   }

//   // HÀM XÓA NHÓM DỊCH VỤ
//   Future<void> _confirmDeleteGroup(ServiceGroupModel group) async {
//     final bool? confirm = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Xóa nhóm dịch vụ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
//         content: Text('Xóa nhóm "${group.name}" sẽ xóa TOÀN BỘ dịch vụ bên trong.\nBạn có chắc chắn muốn xóa không?'),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('Xóa ngay', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );

//     if (confirm != true) return;

//     try {
//       await ServiceApi.deleteServiceGroup(group.id);
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa nhóm thành công!'), backgroundColor: Colors.green));
//         _loadData(); 
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.redAccent));
//       }
//     }
//   }

//   // THẺ NHÓM DỊCH VỤ ĐÃ GẮN SỰ KIỆN SỬA/XÓA
//   Widget _buildGroupCard(ServiceGroupModel group) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(24), 
//         boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           borderRadius: BorderRadius.circular(24),
//           onTap: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => ServiceGroupDetailScreen(storeId: widget.storeId, group: group)),
//             ).then((_) => _loadData()); 
//           },
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//             child: Row(
//               children: [
//                 ClipOval(
//                   child: Image.network(
//                     'https://picsum.photos/100', 
//                     width: 50, height: 50, fit: BoxFit.cover,
//                     errorBuilder: (context, error, stackTrace) => Container(width: 50, height: 50, color: Colors.grey.shade200, child: const Icon(Icons.image, color: Colors.grey)),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
                
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(group.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
//                       const SizedBox(height: 4),
//                       Text('Số dịch vụ: ${group.services.length}', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
//                     ],
//                   ),
//                 ),
                
//                 // NÚT SỬA VÀ XÓA NHÓM BẰNG POPUP MENU
//                 PopupMenuButton<String>(
//                   onSelected: (value) {
//                     if (value == 'edit') {
//                       _openEditGroupBottomSheet(group);
//                     } else if (value == 'delete') {
//                       _confirmDeleteGroup(group);
//                     }
//                   },
//                   itemBuilder: (context) => [
//                     const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 20), SizedBox(width: 8), Text('Sửa nhóm')])),
//                     const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 20), SizedBox(width: 8), Text('Xóa nhóm', style: TextStyle(color: Colors.red))])),
//                   ],
//                   icon: const Icon(Icons.more_vert, color: Colors.grey),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // THẺ DỊCH VỤ TỰ DO ĐÃ GẮN SỰ KIỆN MỞ FORM SỬA
//   Widget _buildSimpleServiceTile(ServiceModel service) {
//     // 🟢 THÊM: Kiểm tra trạng thái hoạt động của dịch vụ
//     bool isActive = service.isActive;

//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 5, offset: const Offset(0, 2))],
//       ),
//       child: ListTile(
//         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         leading: ClipRRect(
//           borderRadius: BorderRadius.circular(8),
//           child: Image.network(
//             // 🟢 THÊM: Hiển thị ảnh thật nếu có, nếu rỗng thì hiện ảnh mặc định
//             (service.imageUrl != null && service.imageUrl!.isNotEmpty) 
//                 ? service.imageUrl! 
//                 : 'https://ui-avatars.com/api/?name=${service.name}&background=random', 
//             width: 50, height: 50, fit: BoxFit.cover,
//             errorBuilder: (context, error, stackTrace) => Container(width: 50, height: 50, color: Colors.grey.shade200, child: const Icon(Icons.image, color: Colors.grey, size: 20)),
//           ),
//         ),
//         title: Text(
//           service.name, 
//           style: TextStyle(
//             fontWeight: FontWeight.w600, 
//             fontSize: 15,
//             // 🟢 THÊM: Nếu dịch vụ đang bị ẩn, làm mờ tên đi một chút để dễ nhận biết
//             color: isActive ? Colors.black87 : Colors.grey,
//           )
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 4),
//             Text('${service.price.toInt()} đ', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
//             if (!isActive) // Hiện chữ thông báo nếu bị ẩn
//               Text('Đang tạm ẩn', style: TextStyle(color: Colors.red.shade400, fontSize: 12, fontStyle: FontStyle.italic)),
//           ],
//         ),
//         trailing: const Icon(Icons.edit_outlined, color: Colors.grey, size: 20),
//         onTap: () {
//           // GỌI BOTTOM SHEET SỬA DỊCH VỤ
//           showModalBottomSheet(
//             context: context,
//             isScrollControlled: true,
//             // 🟢 SỬA LỖI: Đổi transparent thành white + bo góc để Form Sửa hiện đúng nền trắng
//             backgroundColor: Colors.white,
//             shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
//             builder: (context) => EditServiceBottomSheet(
//               storeId: widget.storeId,
//               service: service,
//               groupName: "Dịch vụ tự do",
//               onSuccess: _loadData,
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildErrorState(String error) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(Icons.error_outline, color: Colors.redAccent, size: 60),
//           const SizedBox(height: 16),
//           Text(error.replaceAll('Exception: ', ''), style: const TextStyle(fontSize: 16)),
//           const SizedBox(height: 16),
//           ElevatedButton(onPressed: _loadData, style: ElevatedButton.styleFrom(backgroundColor: primaryColor), child: const Text('Thử lại', style: TextStyle(color: Colors.white)))
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.category_outlined, size: 80, color: Colors.grey.shade300),
//           const SizedBox(height: 16),
//           const Text('Chưa có nhóm dịch vụ nào.', style: TextStyle(color: Colors.grey, fontSize: 16)),
//         ],
//       ),
//     );
//   }
// }



// import 'package:flutter/material.dart';
// import '../models/service_group_model.dart';
// import '../models/service_model.dart';
// import '../services/service_api.dart';
// import '../../../shared/widgets/shared_service_widgets.dart';
// import '../widgets/service_group_bottom_sheet.dart';
// import '../widgets/service_bottom_sheet.dart';
// import '../widgets/service_group_card.dart';
// import '../widgets/free_service_tile.dart';
// import 'service_group_detail_screen.dart';
// import '../../../core/theme/app_colors.dart';


// class ServiceManagementScreen extends StatefulWidget {
//   final int storeId;
//   const ServiceManagementScreen({super.key, required this.storeId});

//   @override
//   State<ServiceManagementScreen> createState() => _ServiceManagementScreenState();
// }

// class _ServiceManagementScreenState extends State<ServiceManagementScreen> {
//   late Future<List<ServiceGroupModel>> _groupedServicesFuture;

//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }

//   void _loadData() {
//     setState(() {
//       _groupedServicesFuture = ServiceApi.getGroupedServices(widget.storeId);
//     });
//   }

//   // Mở BottomSheet Thêm/Sửa Nhóm Dịch Vụ
//   void _openGroupBottomSheet({ServiceGroupModel? group}) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
//       builder: (context) => ServiceGroupBottomSheet(
//         storeId: widget.storeId,
//         group: group,
//         onSuccess: _loadData,
//       ),
//     );
//   }

//   // Mở BottomSheet Thêm/Sửa Dịch vụ Tự do
//   void _openFreeServiceBottomSheet({ServiceModel? service}) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
//       builder: (context) => ServiceBottomSheet(
//         storeId: widget.storeId,
//         service: service,
//         serviceGroupId: 0,
//         groupName: "Dịch vụ tự do",
//         onSuccess: _loadData,
//       ),
//     );
//   }

//   void _confirmDeleteGroup(ServiceGroupModel group) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text('Xác nhận xóa'),
//         content: Text('Bạn có chắc muốn xóa nhóm "${group.name}" không?'),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
//           TextButton(
//             onPressed: () async {
//               Navigator.pop(ctx);
//               try {
//                 await ServiceApi.deleteServiceGroup(group.id);
//                 if (!mounted) return;
//                 SnackBarHelper.showSuccess(context, 'Đã xóa nhóm!');
//                 _loadData();
//               } catch (e) {
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
//       backgroundColor: Colors.grey.shade100, 
//       appBar: AppBar(
//         title: const Text('Quản lý dịch vụ', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
//         centerTitle: true,
//         backgroundColor: AppColors.primary,
//         foregroundColor: AppColors.background,
//         elevation: 0,
//         leading: Padding(
//           padding: const EdgeInsets.all(10.0),
//           child: InkWell(
//             onTap: () => Navigator.pop(context),
//             child: Container(
//               decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
//               child: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.primary),
//             ),
//           ),
//         ),
//       ),
//       body: FutureBuilder<List<ServiceGroupModel>>(
//         future: _groupedServicesFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
//           if (snapshot.hasError) return Center(child: Text("Lỗi: ${snapshot.error}"));
//           if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("Chưa có dữ liệu."));

//           final groups = snapshot.data!;
//           final ungroupedGroup = groups.firstWhere(
//             (g) => g.id == 0,
//             orElse: () => ServiceGroupModel(id: 0, name: '', services: [], storeId: widget.storeId, sortOrder: 0), 
//           );
//           final realGroups = groups.where((g) => g.id != 0).toList();

//           return RefreshIndicator(
//             color: AppColors.primary,
//             onRefresh: () async => _loadData(),
//             child: ListView(
//               padding: const EdgeInsets.all(16),
//               children: [
//                 if (ungroupedGroup.services.isNotEmpty) ...[
//                   const Padding(
//                     padding: EdgeInsets.only(bottom: 12, left: 4),
//                     child: Text("Dịch vụ tự do", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
//                   ),
//                   ...ungroupedGroup.services.map((service) => FreeServiceTile(
//                     service: service,
//                     onTap: () => _openFreeServiceBottomSheet(service: service),
//                   )),
//                   const SizedBox(height: 24),
//                 ],
//                 if (realGroups.isNotEmpty) ...[
//                   const Padding(
//                     padding: EdgeInsets.only(bottom: 12, left: 4),
//                     child: Text("Nhóm dịch vụ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
//                   ),
//                   ...realGroups.map((group) => ServiceGroupCard(
//                     group: group,
//                     onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ServiceGroupDetailScreen(storeId: widget.storeId, group: group))).then((_) => _loadData()),
//                     onEdit: () => _openGroupBottomSheet(group: group),
//                     onDelete: () => _confirmDeleteGroup(group),
//                   )),
//                 ],
//               ],
//             ),
//           );
//         },
//       ),
//       bottomNavigationBar: SafeArea(
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
//           ),
//           child: Row(
//             children: [
//               Expanded(
//                 child: OutlinedButton(
//                   style: OutlinedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     side: const BorderSide(color: AppColors.primary),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                   ),
//                   onPressed: () => _openGroupBottomSheet(),
//                   child: const Text('Thêm Nhóm', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.primary,
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                     elevation: 0,
//                   ),
//                   onPressed: () => _openFreeServiceBottomSheet(),
//                   child: const Text('Thêm Dịch Vụ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


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

// THÊM: Enum quản lý trạng thái lọc
enum ServiceFilter { all, active, inactive }

class ServiceManagementScreen extends StatefulWidget {
  final int storeId;
  const ServiceManagementScreen({super.key, required this.storeId});

  @override
  State<ServiceManagementScreen> createState() => _ServiceManagementScreenState();
}

class _ServiceManagementScreenState extends State<ServiceManagementScreen> {
  late Future<List<ServiceGroupModel>> _groupedServicesFuture;
  
  // THÊM: Biến lưu trạng thái lọc hiện tại
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

  // Mở BottomSheet Thêm/Sửa Nhóm Dịch Vụ
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

  // Mở BottomSheet Thêm/Sửa Dịch vụ Tự do
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
        // THÊM: Nút lọc trên AppBar
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

          // THÊM: Logic lọc dữ liệu thay vì lấy trực tiếp snapshot.data!
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
          // Hết phần logic lọc chèn thêm

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