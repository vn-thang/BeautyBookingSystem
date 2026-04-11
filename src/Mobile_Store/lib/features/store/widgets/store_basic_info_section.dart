import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import 'location_verification.dart';

class StoreBasicInfoSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController addressController;
  final TextEditingController phoneController;
  final TextEditingController zaloController;
  final TextEditingController facebookController;
  final bool isGettingLocation;
  final double? latitude;
  final double? longitude;
  final VoidCallback onOpenMap;
  final VoidCallback onGetGPS;
  final ValueChanged<String> onAddressChanged;

  const StoreBasicInfoSection({
    super.key,
    required this.nameController,
    required this.addressController,
    required this.phoneController,
    required this.zaloController,
    required this.facebookController,
    required this.isGettingLocation,
    this.latitude,
    this.longitude,
    required this.onOpenMap,
    required this.onGetGPS,
    required this.onAddressChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Thông tin chung", style: AppTextStyles.heading1.copyWith(fontSize: 18)),
        const SizedBox(height: 16),
        AppTextField(
          controller: nameController,
          icon: Icons.store_mall_directory_outlined,
          hint: "Tên cửa hàng",
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: addressController,
          icon: Icons.location_on_outlined,
          hint: "Địa chỉ chi tiết",
          onChanged: onAddressChanged,
        ),
        const SizedBox(height: 16),
        LocationVerification(
          isGettingLocation: isGettingLocation,
          latitude: latitude,
          longitude: longitude,
          onOpenMap: onOpenMap,
          onGetGPS: onGetGPS,
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: phoneController,
          icon: Icons.phone_outlined,
          hint: "Số điện thoại",
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: zaloController,
          icon: Icons.chat_bubble_outline, 
          hint: "Số Zalo (VD: 0912345678)",
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: facebookController,
          icon: Icons.link_outlined, 
          hint: "Link Facebook (m.me/...)",
          keyboardType: TextInputType.url,
        ),
      ],
    );
  }
}