import 'package:flutter/material.dart';
import 'package:mobile_store/shared/widgets/feedback/snackbar_helper.dart';
import 'package:mobile_store/shared/widgets/inputs/app_header.dart';
import '../services/store_service.dart';
import '../widgets/store_profile_form.dart';
import '../models/store_profile.dart';
import '../models/operating_hour.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  bool _isSubmitting = false;
  late Future<StoreProfile> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = StoreService.getProfileDetail();
  }

  Future<void> _handleUpdateSubmit(Map<String, dynamic> formData, StoreProfile oldData) async {
    setState(() => _isSubmitting = true);

    try {
      oldData.name = formData['name'] ?? oldData.name;
      oldData.address = formData['address'] ?? oldData.address;
      oldData.latitude = formData['latitude'] ?? oldData.latitude;
      oldData.longitude = formData['longitude'] ?? oldData.longitude;
      oldData.phone = formData['phone'] ?? oldData.phone;
      oldData.description = formData['description'] ?? oldData.description;
      
      oldData.isOpen = formData['isOpen'] ?? oldData.isOpen;
      
      oldData.depositPercent = formData['depositPercent'] ?? oldData.depositPercent; 
      oldData.depositThreshold = formData['depositThreshold'] ?? oldData.depositThreshold; 
      oldData.bankName = formData['bankName']; 
      oldData.bankAccountNumber = formData['bankAccountNumber'];
      oldData.bankAccountName = formData['bankAccountName'];

      if (formData['operatingHours'] != null) {
        oldData.operatingHours = (formData['operatingHours'] as List).map((e) {
          return OperatingHour(
            dayOfWeek: e['dayOfWeek'] ?? 0,
            openTime: e['openTime'] ?? "08:30",
            closeTime: e['closeTime'] ?? "20:30",
            isActive: true, 
          );
        }).toList();
      }

      final success = await StoreService.updateProfile(oldData);

      if (!mounted) return;

      if (success) {
        SnackBarHelper.showSuccess(context, 'Cập nhật thành công!');
        Navigator.pop(context); 
      } else {
        SnackBarHelper.showError(context, 'Cập nhật thất bại. Vui lòng thử lại!');
      }
    } catch (e) {
      if (!mounted) return;
      SnackBarHelper.showError(context, 'Lỗi: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StoreProfile>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppHeader(title: "Đang tải..."),
            body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: const AppHeader(title: "Lỗi"),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error, size: 50),
                  const SizedBox(height: 16),
                  Text("Không thể tải dữ liệu cửa hàng", style: AppTextStyles.bodyText.copyWith(color: AppColors.error)),
                  TextButton(
                    onPressed: () {
                      setState(() => _profileFuture = StoreService.getProfileDetail());
                    }, 
                    child: Text("Thử lại", style: AppTextStyles.bodyText.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
          );
        }

        final profileData = snapshot.data!;

        return StoreProfileForm(
          showAppBar: true, 
          initialData: {
            ...profileData.toJson(),
            'operatingHours': profileData.operatingHours.map((h) => {
              'dayOfWeek': h.dayOfWeek,
              'openTime': h.openTime,
              'closeTime': h.closeTime,
              'isActive': h.isActive, 
            }).toList(),
          }, 
          buttonText: "Cập nhật",
          isSubmitting: _isSubmitting,
          onSubmit: (formData) => _handleUpdateSubmit(formData, profileData),
        );
      },
    );
  }
}