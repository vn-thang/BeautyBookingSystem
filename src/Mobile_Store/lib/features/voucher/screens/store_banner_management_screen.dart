import 'package:flutter/material.dart';
import 'package:mobile_store/features/voucher/widgets/store_banner_form_bottom_sheet.dart';
import 'package:mobile_store/shared/widgets/buttons/app_buttons.dart';
import 'package:mobile_store/shared/widgets/feedback/snackbar_helper.dart';
import 'package:mobile_store/shared/widgets/inputs/app_header.dart';
import '../models/store_banner_model.dart';
import '../services/store_banner_api.dart';
import '../widgets/store_banner_tile.dart';
// import '../widgets/store_banner_form_bottom_sheet.dart'; // Bạn cần tạo file này giống VoucherFormBottomSheet
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class StoreBannerManagementScreen extends StatefulWidget {
  const StoreBannerManagementScreen({super.key});

  @override
  State<StoreBannerManagementScreen> createState() => _StoreBannerManagementScreenState();
}

class _StoreBannerManagementScreenState extends State<StoreBannerManagementScreen> {
  late Future<List<StoreBannerModel>> _bannersFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _bannersFuture = StoreBannerApi.getBanners();
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

  void _openFormBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, 
      builder: (context) => Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20),
        child: StoreBannerFormBottomSheet(
          onSuccess: _loadData, // Tải lại danh sách banner sau khi thêm thành công
        ),
      ),
    );
  }

  Future<void> _toggleStatus(StoreBannerModel banner) async {
    try {
      // Đảo trạng thái tạm thời trên UI cho mượt
      setState(() => banner.isActive = !banner.isActive);
      
      // Gọi API thực tế
      final newStatus = await StoreBannerApi.toggleStatus(banner.id);
      
      // Cập nhật lại trạng thái chuẩn từ Server
      setState(() => banner.isActive = newStatus);
    } catch (e) {
      // Nếu lỗi thì hoàn tác lại UI
      setState(() => banner.isActive = !banner.isActive);
      _showMessage('Lỗi cập nhật trạng thái: $e', isError: true);
    }
  }

  Future<void> _confirmDelete(StoreBannerModel banner) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusLarge)),
        title: Text('Xóa banner', style: AppTextStyles.heading1.copyWith(fontSize: 20)),
        contentPadding: const EdgeInsets.only(
          left: AppDimens.paddingLarge, 
          right: AppDimens.paddingLarge, 
          top: AppSpacing.md, 
          bottom: AppDimens.paddingLarge
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Bạn có chắc muốn xóa banner này không? Hành động này không thể hoàn tác.', style: AppTextStyles.bodyText),
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
        await StoreBannerApi.deleteBanner(banner.id);
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
      appBar: const AppHeader(title: 'Quản lý Banner'),
      body: FutureBuilder<List<StoreBannerModel>>(
        future: _bannersFuture,
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
              padding: const EdgeInsets.all(AppDimens.paddingLarge),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final banner = snapshot.data![index];
                return StoreBannerTile(
                  banner: banner,
                  onToggleStatus: (val) => _toggleStatus(banner),
                  onDelete: () => _confirmDelete(banner),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: SizedBox(
        height: 44, 
        child: FloatingActionButton.extended(
          onPressed: _openFormBottomSheet,
          backgroundColor: AppColors.primary,
          elevation: 4, 
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100), 
          ),
          icon: const Icon(Icons.add_photo_alternate, color: AppColors.white, size: 20), 
          label: Text(
            "Thêm Banner", 
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
          Icon(Icons.view_carousel_outlined, size: 80, color: AppColors.textSub.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text('Chưa có banner quảng cáo nào.', style: AppTextStyles.bodyText.copyWith(color: AppColors.textSub, fontSize: 16)),
        ],
      ),
    );
  }
}