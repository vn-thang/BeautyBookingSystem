import 'package:flutter/material.dart';
import 'package:mobile_store/shared/widgets/feedback/snackbar_helper.dart';
import 'package:mobile_store/shared/widgets/inputs/app_header.dart';
import '../services/store_service.dart';
import '../widgets/store_profile_form.dart';
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

    try {
      formData['averageRating'] = 0.0;
      formData['totalReviews'] = 0;

      final profilePayload = StoreProfile.fromJson(formData);
      final isSuccess = await StoreService.updateProfile(profilePayload);

      if (!mounted) return;
      
      setState(() => _isLoading = false);

      if (isSuccess) {
        FocusManager.instance.primaryFocus?.unfocus();
        SnackBarHelper.showSuccess(context, "Thông tin đã được lưu thành công!");
        Future.delayed(const Duration(milliseconds: 300), () {
          if (!mounted) return;
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home', 
            (route) => false,
          );
        });
      }
    } catch (e) {
      if (!mounted) return;
      
      setState(() => _isLoading = false);
      String errorMessage = e.toString().replaceAll("Exception: ", "");
      SnackBarHelper.showError(context, errorMessage);
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