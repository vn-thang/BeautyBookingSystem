import 'package:flutter/material.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Thông tin đã được gửi!"), backgroundColor: Colors.green),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Có lỗi xảy ra, vui lòng thử lại!"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Thiết lập cửa hàng",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
      ),
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