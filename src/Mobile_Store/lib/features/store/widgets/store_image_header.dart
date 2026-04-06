import 'package:flutter/material.dart';
import '../../../shared/widgets/inputs/app_image_picker.dart'; 
import '../../../core/theme/app_colors.dart';

class StoreImageHeader extends StatelessWidget {
  final String coverUrl; 
  final String logoUrl;
  
  final ValueChanged<String> onCoverUploaded;
  final ValueChanged<String> onLogoUploaded;

  const StoreImageHeader({
    super.key,
    required this.coverUrl,
    required this.logoUrl,
    required this.onCoverUploaded,
    required this.onLogoUploaded,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240, 
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          SizedBox(
            height: 180,
            width: double.infinity, 
            child: AppImagePicker(
              folderName: 'stores/covers', 
              isCircle: false, 
              width: double.infinity,
              height: 180,
              initialImageUrl: coverUrl.isNotEmpty ? coverUrl : null,
              onImageUploaded: onCoverUploaded,
            ),
          ),

          Positioned(
            bottom: 10, 
            child: Container(
              padding: const EdgeInsets.all(4), 
              decoration: const BoxDecoration(
                color: AppColors.white, 
                shape: BoxShape.circle,
              ),
              child: AppImagePicker(
                folderName: 'stores/logos', 
                isCircle: true, 
                width: 90,
                height: 90,
                initialImageUrl: logoUrl.isNotEmpty ? logoUrl : null,
                onImageUploaded: onLogoUploaded,
              ),
            ),
          ),
        ],
      ),
    );
  }
}