// import 'package:flutter/material.dart';
// import '../../domain/entities/global_category.dart';

// class GlobalCategorySection extends StatelessWidget {
//   final List<GlobalCategory> categories;

//   const GlobalCategorySection({super.key, required this.categories});

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 90,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: categories.length,
//         itemBuilder: (context, index) {
//           final item = categories[index];

//           return Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 8),
//             child: Column(
//               children: [
//                 CircleAvatar(
//                   radius: 30,
//                   child: Text(item.name[0]),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(item.name),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import '../../domain/entities/global_category.dart';

class GlobalCategorySection extends StatelessWidget {
  final List<GlobalCategory> categories;

  const GlobalCategorySection({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 115, // 1. TĂNG CHIỀU CAO TỔNG THỂ LÊN (90 -> 115) để chữ có không gian thở
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final item = categories[index];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SizedBox(
              width: 75, // 2. Bọc thêm SizedBox giới hạn chiều rộng để chữ biết đường mà cắt (...)
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 30,
                    child: Text(item.name[0]),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.name,
                    textAlign: TextAlign.center, // Canh giữa chữ cho đẹp
                    maxLines: 2,                 // 3. Chỉ cho phép chữ dài tối đa 2 dòng
                    overflow: TextOverflow.ellipsis, // 4. Nếu dài hơn 2 dòng thì tự động hiện "..."
                    style: const TextStyle(
                      fontSize: 12, // Ép size chữ nhỏ lại một chút cho an toàn
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}