import 'package:flutter/material.dart';
import '../models/voucher_model.dart';
import '../services/voucher_api.dart';
import '../widgets/voucher_tile.dart';
import '../widgets/voucher_form_bottom_sheet.dart';
import '../../../core/theme/app_colors.dart';

class VoucherManagementScreen extends StatefulWidget {
  const VoucherManagementScreen({super.key});

  @override
  State<VoucherManagementScreen> createState() => _VoucherManagementScreenState();
}

class _VoucherManagementScreenState extends State<VoucherManagementScreen> {
  late Future<List<VoucherModel>> _vouchersFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _vouchersFuture = VoucherApi.getVouchers();
    });
  }
  void _showMessage(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: isError ? Colors.red : Colors.green),
    );
  }

  void _openFormBottomSheet({VoucherModel? voucher}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => VoucherFormBottomSheet(
        voucher: voucher,
        onSuccess: _loadData,
      ),
    );
  }

  Future<void> _confirmDelete(VoucherModel voucher) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa khuyến mãi'),
        content: Text('Bạn có chắc muốn xóa mã ${voucher.code}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await VoucherApi.deleteVoucher(voucher.id);
        _loadData();
        _showMessage('Xóa thành công');
      } catch (e) {
        _showMessage(e.toString(), isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Quản lý Khuyến mãi', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<VoucherModel>>(
        future: _vouchersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (snapshot.hasError) return Center(child: Text('Lỗi: ${snapshot.error}'));
          if (!snapshot.hasData || snapshot.data!.isEmpty) return _buildEmptyState();

          return RefreshIndicator(
            onRefresh: () async => _loadData(),
            color: AppColors.primary,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final voucher = snapshot.data![index];
                return VoucherTile(
                  voucher: voucher,
                  onEdit: () => _openFormBottomSheet(voucher: voucher),
                  onDelete: () => _confirmDelete(voucher),
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
        label: const Text("Tạo Voucher", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_offer_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('Chưa có mã khuyến mãi nào.', style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}