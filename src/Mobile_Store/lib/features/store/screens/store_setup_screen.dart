import 'package:flutter/material.dart';
import 'package:mobile_store/shared/widgets/feedback/snackbar_helper.dart';
import 'package:mobile_store/shared/widgets/inputs/app_header.dart';
import '../services/store_service.dart';
import '../widgets/store_profile_form.dart';
import '../../home/screens/main_screen.dart';
import '../models/store_profile.dart';
import '../../../core/theme/app_colors.dart';

class StoreSetupScreen extends StatefulWidget {
  const StoreSetupScreen({super.key});

  @override
  State<StoreSetupScreen> createState() => _StoreSetupScreenState();
}

class _StoreSetupScreenState extends State<StoreSetupScreen> {
  bool _isLoading = false;

  Future<void> _handleSetupSubmit(Map<String, dynamic> formData) async {
    setState(() => _isLoading = true);

    formData['averageRating'] = 0.0;
    formData['totalReviews'] = 0;

    final profilePayload = StoreProfile.fromJson(formData);
    final isSuccess = await StoreService.updateProfile(profilePayload);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (isSuccess) {
      SnackBarHelper.showSuccess(context, "Thông tin đã được gửi!");
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
        (route) => false,
      );
    } else {
      SnackBarHelper.showError(context, "Có lỗi xảy ra, vui lòng thử lại!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(title: "Thiết lập cửa hàng"), 
      body: StoreProfileForm(
        showAppBar: false, 
        initialData: null,
        buttonText: "Bắt đầu kinh doanh",
        isSubmitting: _isLoading,
        onSubmit: _handleSetupSubmit,
      ),
    );
  }
}