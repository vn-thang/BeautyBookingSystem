// import 'package:flutter/material.dart';

// class StoreImageHeader extends StatelessWidget {
//   final TextEditingController coverUrlController;
//   final TextEditingController logoUrlController;
//   final VoidCallback onPickCover;
//   final VoidCallback onPickLogo;

//   const StoreImageHeader({
//     super.key,
//     required this.coverUrlController,
//     required this.logoUrlController,
//     required this.onPickCover,
//     required this.onPickLogo,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 240,
//       child: Stack(
//         alignment: Alignment.topCenter,
//         clipBehavior: Clip.none,
//         children: [
//           Container(
//             height: 180, width: double.infinity, color: Colors.grey.shade300,
//             child: coverUrlController.text.isNotEmpty
//                 ? Image.network(coverUrlController.text, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image, size: 50, color: Colors.grey))
//                 : const Icon(Icons.wallpaper, size: 50, color: Colors.grey),
//           ),
//           Positioned(
//             top: 15, right: 15,
//             child: OutlinedButton(
//               onPressed: onPickCover,
//               style: OutlinedButton.styleFrom(
//                 backgroundColor: Colors.black.withValues(alpha: 0.5), 
//                 side: const BorderSide(color: Colors.white), 
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
//               ),
//               child: const Text("Thay ảnh bìa", style: TextStyle(color: Colors.white)),
//             ),
//           ),
//           Positioned(
//             bottom: 0, left: 0, right: 0,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 CircleAvatar(
//                   radius: 45, backgroundColor: Colors.white,
//                   child: CircleAvatar(
//                     radius: 42, backgroundColor: Colors.grey.shade200,
//                     backgroundImage: logoUrlController.text.isNotEmpty ? NetworkImage(logoUrlController.text) : null,
//                     child: logoUrlController.text.isEmpty ? const Icon(Icons.person, size: 40, color: Colors.grey) : null,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 OutlinedButton(
//                   onPressed: onPickLogo,
//                   style: OutlinedButton.styleFrom(
//                     minimumSize: const Size(80, 25), 
//                     padding: const EdgeInsets.symmetric(horizontal: 10), 
//                     side: const BorderSide(color: Colors.grey), // Đã lấy lại viền xám gốc
//                     backgroundColor: Colors.white,
//                   ),
//                   child: const Text("Thay ảnh", style: TextStyle(color: Colors.black87, fontSize: 12)),
//                 )
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
// Đừng quên import đường dẫn tới AppImagePicker của bạn nhé
import '../../../shared/widgets/app_image_picker.dart'; 

class StoreImageHeader extends StatelessWidget {
  // Thay TextEditingController bằng String
  final String coverUrl; 
  final String logoUrl;
  
  // Trả về link ảnh mới mỗi khi upload thành công
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
      height: 240, // Tổng chiều cao của cụm Header
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          // --- 1. ẢNH BÌA (COVER) ---
          SizedBox(
            height: 180,
            width: double.infinity, // Trải dài toàn màn hình
            child: AppImagePicker(
              folderName: 'stores/covers', // Lưu vào thư mục covers
              isCircle: false, // Ảnh bìa là hình chữ nhật
              width: double.infinity,
              height: 180,
              initialImageUrl: coverUrl.isNotEmpty ? coverUrl : null,
              onImageUploaded: onCoverUploaded,
            ),
          ),

          // --- 2. ẢNH LOGO (Nằm đè lên mép dưới ảnh bìa) ---
          Positioned(
            bottom: 10, 
            child: Container(
              // Tạo một lớp viền trắng dày 4px bao quanh Logo cho nổi bật
              padding: const EdgeInsets.all(4), 
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: AppImagePicker(
                folderName: 'stores/logos', // Lưu vào thư mục logos
                isCircle: true, // Logo thì bo tròn
                width: 90, // Bằng với radius 45 * 2 của code cũ
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