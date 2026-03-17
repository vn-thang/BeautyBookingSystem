import 'package:flutter/material.dart';

class PendingBanner extends StatelessWidget {
  const PendingBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.orange.shade100,
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tài khoản đang chờ duyệt. Một số tính năng thống kê tạm thời bị khóa.',
              style: TextStyle(color: Colors.orange.shade900, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}