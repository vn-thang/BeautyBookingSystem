import 'package:flutter/material.dart';
import 'package:mobile_store/shared/widgets/buttons/app_buttons.dart';
import 'package:mobile_store/shared/widgets/feedback/snackbar_helper.dart';
import 'package:mobile_store/shared/widgets/inputs/app_header.dart';
import '../models/voucher_model.dart';
import '../services/voucher_api.dart';
import '../widgets/voucher_tile.dart';
import '../widgets/voucher_form_bottom_sheet.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
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
    if (isError) {
      SnackBarHelper.showError(context, msg);
    } else {
      SnackBarHelper.showSuccess(context, msg);
    }
  }

  void _openFormBottomSheet({VoucherModel? voucher}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, 
      builder: (context) => Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20),
        child: VoucherFormBottomSheet(
          voucher: voucher,
          onSuccess: _loadData,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(VoucherModel voucher) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusLarge)),
        title: Text('Xóa khuyến mãi', style: AppTextStyles.heading1.copyWith(fontSize: 20)),
        contentPadding: const EdgeInsets.only(
          left: AppDimens.paddingLarge, 
          right: AppDimens.paddingLarge, 
          top: AppSpacing.md, 
          bottom: AppDimens.paddingLarge
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Bạn có chắc muốn xóa mã ${voucher.code}?', style: AppTextStyles.bodyText),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: AppOutlineButton(
                    text: 'Hủy',
                    color: AppColors.textSub, 
                    onTap: () => Navigator.pop(context, false),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppPrimaryButton(
                    text: 'Xóa',
                    color: AppColors.error, 
                    onPressed: () => Navigator.pop(context, true),
                  ),
                ),
              ],
            ),
          ],
        ),
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
      backgroundColor: AppColors.background,
      appBar: const AppHeader(title: 'Quản lý Khuyến mãi'),
      body: FutureBuilder<List<VoucherModel>>(
        future: _vouchersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}', style: AppTextStyles.bodyText.copyWith(color: AppColors.error)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) return _buildEmptyState();

          return RefreshIndicator(
            onRefresh: () async => _loadData(),
            color: AppColors.primary,
            child: ListView.builder(
              padding: const EdgeInsets.only(
                left: AppDimens.paddingLarge,
                right: AppDimens.paddingLarge,
                top: AppDimens.paddingLarge,
                bottom: 100,
              ),
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
      floatingActionButton: SizedBox(
        height: 44, 
        child: FloatingActionButton.extended(
          onPressed: () => _openFormBottomSheet(),
          backgroundColor: AppColors.primary,
          elevation: 4, 
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100), 
          ),
          icon: const Icon(Icons.add, color: AppColors.white, size: 20), 
          label: Text(
            "Tạo Voucher", 
            style: AppTextStyles.bodyText.copyWith(
              color: AppColors.white, 
              fontWeight: FontWeight.w600, 
              fontSize: 13, 
            ),
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
          Icon(Icons.local_offer_outlined, size: 80, color: AppColors.textSub.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text('Chưa có mã khuyến mãi nào.', style: AppTextStyles.bodyText.copyWith(color: AppColors.textSub, fontSize: 16)),
        ],
      ),
    );
  }
}