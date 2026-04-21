import 'package:flutter/material.dart';
import 'package:mobile_store/shared/widgets/buttons/app_buttons.dart';
import 'package:mobile_store/shared/widgets/feedback/snackbar_helper.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/inputs/app_text_field.dart'; 
import '../../../shared/widgets/inputs/app_image_picker.dart'; 
import '../services/store_banner_api.dart';

class StoreBannerFormBottomSheet extends StatefulWidget {
  final VoidCallback onSuccess;

  const StoreBannerFormBottomSheet({super.key, required this.onSuccess});

  @override
  State<StoreBannerFormBottomSheet> createState() => _StoreBannerFormBottomSheetState();
}

class _StoreBannerFormBottomSheetState extends State<StoreBannerFormBottomSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _sortOrderCtrl = TextEditingController(text: '0'); 
  
  String _imageUrl = ''; 
  bool _isSubmitting = false;  
  
  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _sortOrderCtrl.dispose();
    super.dispose();
  }

  void _showMessage(String msg, {bool isError = false}) {
    if (!mounted) return;
    if (isError) {
      SnackBarHelper.showError(context, msg);
    } else {
      SnackBarHelper.showSuccess(context, msg);
    }
  }

  int _parseInt(String value) => int.tryParse(value.trim()) ?? 0;

  Future<void> _submit() async {
    if (_imageUrl.trim().isEmpty) {
      return _showMessage('Vui lòng tải lên hình ảnh Banner!', isError: true);
    }

    setState(() => _isSubmitting = true);

    try {
      await StoreBannerApi.addBanner(
        imageUrl: _imageUrl,
        title: _titleCtrl.text.trim().isNotEmpty ? _titleCtrl.text.trim() : null,
        description: _descCtrl.text.trim().isNotEmpty ? _descCtrl.text.trim() : null,
        sortOrder: _parseInt(_sortOrderCtrl.text),
      );

      if (!mounted) return;
      
      widget.onSuccess(); 
      Navigator.pop(context); 
      _showMessage('Thêm Banner thành công!');
      
    } catch (e) {
      _showMessage(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90, 
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusLarge)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom, 
          left: AppDimens.paddingLarge, 
          right: AppDimens.paddingLarge, 
          top: AppDimens.paddingLarge
        ),
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: SingleChildScrollView( 
            child: Column(
              mainAxisSize: MainAxisSize.min, 
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                
                Text('Thêm Banner Quảng Cáo', style: AppTextStyles.heading1.copyWith(fontSize: 20)),
                const SizedBox(height: AppSpacing.lg),

                Center(
                  child: AppImagePicker(
                    folderName: 'store_banners', 
                    isCircle: false,      
                    width: double.infinity,          
                    height: 160, 
                    initialImageUrl: null,
                    onImageUploaded: (url) {
                      setState(() {
                        _imageUrl = url; 
                      });
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Center(
                  child: Text('Tỷ lệ ảnh khuyến nghị: 21:9', style: AppTextStyles.labelSmall),
                ),
                const SizedBox(height: AppSpacing.xl),
                
                AppTextField(
                  controller: _titleCtrl, 
                  label: 'Tiêu đề Banner (Tùy chọn)', 
                  hint: 'VD: Khuyến mãi mùng 8/3', 
                  icon: Icons.title_outlined,
                ),
                const SizedBox(height: AppSpacing.md),
                
                AppTextField(
                  controller: _descCtrl, 
                  label: 'Mô tả ngắn gọn (Tùy chọn)', 
                  hint: 'Nhập nội dung...', 
                  icon: Icons.description_outlined,
                ),
                const SizedBox(height: AppSpacing.md),

                AppTextField(
                  controller: _sortOrderCtrl, 
                  label: 'Thứ tự hiển thị', 
                  hint: 'VD: 0, 1, 2...', 
                  icon: Icons.sort_outlined, 
                  keyboardType: TextInputType.number
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '* Số nhỏ hơn sẽ được hiển thị trước (0 là vị trí đầu tiên).', 
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSub)
                ),
                
                const SizedBox(height: AppSpacing.xl),
                
                AppPrimaryButton(
                  text: 'LƯU BANNER',
                  isLoading: _isSubmitting,
                  onPressed: _submit,
                ),
                const SizedBox(height: AppDimens.paddingLarge),
              ],
            ),
          ),
        ),
      ),
    );
  }
}