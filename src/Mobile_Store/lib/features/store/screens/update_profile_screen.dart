// import 'package:flutter/material.dart';
// import '../services/store_service.dart';
// import '../widgets/store_profile_form.dart'; 

// class UpdateProfileScreen extends StatefulWidget {
//   const UpdateProfileScreen({super.key});

//   @override
//   State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
// }

// class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
//   bool _isSubmitting = false; // Biến quản lý trạng thái loading của nút Submit

//   Future<void> _handleUpdateSubmit(Map<String, dynamic> formData, Map<String, dynamic> oldData) async {
//     // Bật hiệu ứng xoay tròn ở nút "Cập nhật"
//     setState(() => _isSubmitting = true); 

//     try {
//       // Giữ lại các trường không cho sửa của dữ liệu cũ
//       formData['averageRating'] = oldData['averageRating'] ?? 0.0;
//       formData['totalReviews'] = oldData['totalReviews'] ?? 0;

//       final success = await StoreService.updateProfile(formData);

//       if (mounted) {
//         if (success) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Cập nhật thành công!'), backgroundColor: Colors.green)
//           );
//           Navigator.pop(context); // Cập nhật xong thì quay về màn trước
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Cập nhật thất bại. Vui lòng thử lại!'), backgroundColor: Colors.red)
//           );
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red)
//         );
//       }
//     } finally {
//       // Dù thành công hay thất bại cũng phải tắt hiệu ứng loading
//       if (mounted) setState(() => _isSubmitting = false); 
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Chỉ dùng FutureBuilder để bọc ngoài cùng
//     return FutureBuilder<Map<String, dynamic>?>(
//       future: StoreService.getProfileDetail(), // API lấy data
//       builder: (context, snapshot) {
        
//         // Trạng thái đang tải dữ liệu từ API
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Scaffold(
//             backgroundColor: Colors.white,
//             appBar: AppBar(backgroundColor: const Color(0xFFD84B6B), elevation: 0),
//             body: const Center(child: CircularProgressIndicator(color: Color(0xFFD84B6B))),
//           );
//         }

//         // Trạng thái lỗi hoặc không có dữ liệu
//         if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
//           return Scaffold(
//             backgroundColor: Colors.white,
//             appBar: AppBar(backgroundColor: const Color(0xFFD84B6B), elevation: 0),
//             body: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(Icons.error_outline, color: Colors.red, size: 50),
//                   const SizedBox(height: 16),
//                   const Text("Không thể tải dữ liệu cửa hàng", style: TextStyle(color: Colors.red, fontSize: 16)),
//                   TextButton(
//                     onPressed: () => setState(() {}), // Gọi lại FutureBuilder
//                     child: const Text("Thử lại", style: TextStyle(color: Color(0xFFD84B6B))),
//                   )
//                 ],
//               ),
//             ),
//           );
//         }

//         // Trạng thái thành công: Trả thẳng về StoreProfileForm
//         // (Vì StoreProfileForm bây giờ bản thân nó đã là 1 Scaffold có AppBar rồi)
//         final profileData = snapshot.data!;

//         return StoreProfileForm(
//           initialData: profileData, 
//           buttonText: "Cập nhật", // Đổi text cho phù hợp
//           isSubmitting: _isSubmitting, // Truyền biến loading vào form
//           onSubmit: (formData) => _handleUpdateSubmit(formData, profileData),
//         );
//       },
//     );
//   }
// }

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
      future: _profileFuture, // Sử dụng biến Future đã khởi tạo
      builder: (context, snapshot) {
        // Trạng thái đang tải dữ liệu từ API
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(backgroundColor: AppColors.primary, elevation: 0),
            body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }

        // Trạng thái lỗi hoặc không có dữ liệu
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
                      // Gán lại Future để load lại data
                      setState(() => _profileFuture = StoreService.getProfileDetail());
                    }, 
                    child: const Text("Thử lại", style: TextStyle(color: AppColors.primary)),
                  )
                ],
              ),
            ),
          );
        }

        // Trạng thái thành công
        final profileData = snapshot.data!;

      return StoreProfileForm(
          showAppBar: true, 
          // FIX LỖI Ở ĐÂY: Ép Form nhận ĐỦ 7 ngày thay vì bị filter mất bởi hàm toJson()
          initialData: {
            ...profileData.toJson(),
            'operatingHours': profileData.operatingHours.map((h) => {
              'dayOfWeek': h.dayOfWeek,
              'openTime': h.openTime,
              'closeTime': h.closeTime,
              'isActive': h.isActive, // Rất quan trọng: Phải cho form biết ngày này tắt hay bật
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