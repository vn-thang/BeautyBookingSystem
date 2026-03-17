import 'package:flutter/material.dart';

class PermissionDialog {
  /// Hàm hiển thị bảng xin quyền (Soft Prompt) có thể tái sử dụng
  static Future<bool> showCustomPrompt({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    String confirmText = 'Cho phép',
    String cancelText = 'Để sau',
    Color primaryColor = Colors.pink, // Đổi màu theo theme app của bạn
  }) async {
    // showDialog trả về Future<bool?> nên ta await nó
    bool? userAgreed = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // Bắt buộc người dùng phải chọn 1 trong 2 nút
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Tự động co giãn theo nội dung
              children: [
                // Icon động đậy xíu cho đẹp
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 48, color: primaryColor),
                ),
                const SizedBox(height: 20),
                
                // Tiêu đề
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                
                // Nội dung giải thích lý do
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.5),
                ),
                const SizedBox(height: 24),
                
                // Hai nút bấm
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, false), // Trả về false
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(cancelText, style: const TextStyle(color: Colors.grey)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true), // Trả về true
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(confirmText, style: const TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    // Nếu user bấm ra ngoài (dù đã set barrierDismissible) hoặc có lỗi, mặc định là false
    return userAgreed ?? false;
  }
}