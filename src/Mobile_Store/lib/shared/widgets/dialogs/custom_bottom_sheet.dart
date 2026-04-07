// import 'package:flutter/material.dart';
// import 'package:mobile_store/core/theme/app_dimens.dart';
// import 'package:mobile_store/core/theme/app_text_styles.dart';
// import '../../../core/theme/app_colors.dart';

// class CustomBottomSheetHeader extends StatelessWidget {
//   final String title;

//   const CustomBottomSheetHeader({super.key, required this.title});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//       decoration: const BoxDecoration(
//         color: AppColors.primary,
//        borderRadius: BorderRadius.vertical(
//   top: Radius.circular(AppDimens.radiusLarge),
// ),
//       ),
//       child: Row(
//         children: [
//           Container(
//             decoration: const BoxDecoration(
//               color: Colors.white,
//               shape: BoxShape.circle,
//             ),
//             child: IconButton(
//               icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.primary),
//               onPressed: () => Navigator.pop(context),
//               constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
//               padding: EdgeInsets.zero,
//             ),
//           ),
//           Expanded(
//             child: Center(
//               child: Text(
//   title,
//   style: AppTextStyles.appBarTitle,
// ),
//             ),
//           ),
//           const SizedBox(width: 36), 
//         ],
//       ),
//     );
//   }
// }