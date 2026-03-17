import 'package:flutter/material.dart';
import '../services/store_service.dart';
import '../widgets/store_profile_form.dart';
import '../models/store_profile.dart';
import '../models/operating_hour.dart';
import '../../../core/theme/app_colors.dart';

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
      oldData.phone = formData['phone'] ?? oldData.phone;
      oldData.description = formData['description'] ?? oldData.description;
      
     
      oldData.isOpen = formData['isOpen'] ?? oldData.isOpen;

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật thành công!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context); 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật thất bại. Vui lòng thử lại!'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
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
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(backgroundColor: AppColors.primary, elevation: 0),
            body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(backgroundColor: AppColors.primary, elevation: 0),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 50),
                  const SizedBox(height: 16),
                  const Text("Không thể tải dữ liệu cửa hàng", style: TextStyle(color: Colors.red, fontSize: 16)),
                  TextButton(
                    onPressed: () {
                      setState(() => _profileFuture = StoreService.getProfileDetail());
                    }, 
                    child: const Text("Thử lại", style: TextStyle(color: AppColors.primary)),
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