
import 'package:flutter/material.dart';
import '../models/staff_model.dart';
import '../services/staff_api.dart';
import '../widgets/staff_tile.dart';
import '../widgets/staff_form_bottom_sheet.dart';
import '../../../core/theme/app_colors.dart';

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

  void _showMessage(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: isError ? Colors.red : Colors.green),
    );
  }

  void _openFormBottomSheet({StaffModel? staff}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StaffFormBottomSheet(
        staff: staff,
        onSuccess: _loadData,
      ),
    );
  }

  Future<void> _confirmDelete(StaffModel staff) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận ẩn'),
        content: Text('Bạn có chắc chắn muốn ẩn nhân viên "${staff.fullName}" không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ẩn', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await StaffApi.deleteStaff(staff.id);
        _loadData();
        _showMessage('Đã ẩn nhân viên');
      } catch (e) {
        _showMessage('Lỗi: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Quản lý Nhân viên', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<bool>(
            icon: const Icon(Icons.filter_list_rounded, color: Colors.white),
            tooltip: 'Lọc danh sách',
            onSelected: (bool value) {
              if (_showOnlyActive != value) {
                setState(() => _showOnlyActive = value);
                _loadData();
              }
            },
            itemBuilder: (context) => [
              CheckedPopupMenuItem<bool>(
                value: true,
                checked: _showOnlyActive == true,
                child: const Text('Chỉ người đang làm'),
              ),
              CheckedPopupMenuItem<bool>(
                value: false,
                checked: _showOnlyActive == false,
                child: const Text('Tất cả (Gồm đã ẩn)'),
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder<List<StaffModel>>(
        future: _staffsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: AppColors.primary));
          } 
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } 
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final staffs = snapshot.data!;
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async => _loadData(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openFormBottomSheet(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Thêm nhân viên", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_alt_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            _showOnlyActive ? 'Chưa có nhân viên nào đang làm.' : 'Chưa có nhân viên nào.',
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}