// import 'package:flutter/material.dart';
// import '../models/staff_model.dart';

// class StaffTile extends StatelessWidget {
//   final StaffModel staff;
//   final VoidCallback onEdit;
//   final VoidCallback onDelete;

//   const StaffTile({
//     super.key,
//     required this.staff,
//     required this.onEdit,
//     required this.onDelete,
//   });

//   @override
//   Widget build(BuildContext context) {
//     const primaryColor = Color(0xFFDE4660);

//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.03),
//             blurRadius: 8,
//             offset: const Offset(0, 3),
//           )
//         ],
//       ),
//       child: ListTile(
//         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         leading: CircleAvatar(
//           radius: 25,
//           backgroundColor: Colors.grey.shade200,
//           backgroundImage: (staff.avatarUrl != null && staff.avatarUrl!.isNotEmpty)
//               ? NetworkImage(staff.avatarUrl!)
//               : NetworkImage('https://ui-avatars.com/api/?name=${staff.fullName}&background=random'),
//         ),
//         title: Text(
//           staff.fullName,
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 16,
//             color: staff.isActive ? Colors.black87 : Colors.grey,
//             decoration: staff.isActive ? TextDecoration.none : TextDecoration.lineThrough,
//           ),
//         ),
//         subtitle: Padding(
//           padding: const EdgeInsets.only(top: 4),
//           child: Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                 decoration: BoxDecoration(
//                   color: primaryColor.withValues(alpha: 0.1),
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//                 child: Text(
//                   staff.position,
//                   style: const TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.w600),
//                 ),
//               ),
//               if (!staff.isActive) ...[
//                 const SizedBox(width: 8),
//                 const Text('Đã nghỉ/Ẩn', style: TextStyle(color: Colors.redAccent, fontSize: 12, fontStyle: FontStyle.italic)),
//               ]
//             ],
//           ),
//         ),
//         trailing: PopupMenuButton<String>(
//           onSelected: (value) {
//             if (value == 'edit') onEdit();
//             if (value == 'delete') onDelete();
//           },
//           itemBuilder: (context) => [
//             const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 20), SizedBox(width: 8), Text('Sửa thông tin')])),
//             const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 20), SizedBox(width: 8), Text('Xóa/Ẩn', style: TextStyle(color: Colors.red))])),
//           ],
//           icon: const Icon(Icons.more_vert, color: Colors.grey),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import '../models/staff_model.dart';

class StaffTile extends StatelessWidget {
  final StaffModel staff;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const StaffTile({
    super.key,
    required this.staff,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFDE4660);
    final hasAvatar = staff.avatarUrl != null && staff.avatarUrl!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.grey.shade200,
          backgroundImage: hasAvatar
              ? NetworkImage(staff.avatarUrl!)
              : NetworkImage('https://ui-avatars.com/api/?name=${staff.fullName}&background=random'),
          // Chống crash app nếu link ảnh bị chết (lỗi 404, etc.)
          onBackgroundImageError: (_, _) {}, 
        ),
        title: Text(
          staff.fullName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: staff.isActive ? Colors.black87 : Colors.grey,
            decoration: staff.isActive ? TextDecoration.none : TextDecoration.lineThrough,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          // Thay Row bằng Wrap để tự xuống dòng nếu chữ quá dài, chống lỗi sọc vàng đen
          child: Wrap(
            spacing: 8, 
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  staff.position,
                  style: const TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
              if (!staff.isActive)
                const Text('Đã nghỉ/Ẩn', style: TextStyle(color: Colors.redAccent, fontSize: 12, fontStyle: FontStyle.italic)),
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') onEdit();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 20), SizedBox(width: 8), Text('Sửa thông tin')])),
            const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 20), SizedBox(width: 8), Text('Xóa/Ẩn', style: TextStyle(color: Colors.red))])),
          ],
          icon: const Icon(Icons.more_vert, color: Colors.grey),
        ),
      ),
    );
  }
}