import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';

class ContactSupportScreen extends StatelessWidget {
  const ContactSupportScreen({super.key});

  // 1. Logic gọi Điện thoại
  Future<void> _makePhoneCall(BuildContext context, String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    _launchInExternalApp(context, launchUri);
  }

  // 2. Logic gửi Email
  Future<void> _sendEmail(BuildContext context) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@beautybooking.com', // Thay bằng email thật của bạn
      queryParameters: {
        'subject': 'Cần hỗ trợ từ BeautyBooking',
      },
    );
    _launchInExternalApp(context, emailLaunchUri);
  }

  // 3. Logic mở Zalo (Có thể dùng số điện thoại hoặc link Zalo OA)
  Future<void> _openZalo(BuildContext context, String phoneNumber) async {
    final Uri zaloUri = Uri.parse('https://zalo.me/$phoneNumber');
    
    try {
      // Thử mở thẳng app Zalo (externalApplication)
      bool launched = await launchUrl(zaloUri, mode: LaunchMode.externalApplication);
      
      // Nếu không mở được app Zalo (do máy không cài), thử mở bằng trình duyệt web
      if (!launched) {
        await launchUrl(zaloUri, mode: LaunchMode.inAppBrowserView);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể kết nối tới Zalo. Vui lòng thử lại!'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Hàm helper chung để mở link và bắt lỗi
  Future<void> _launchInExternalApp(BuildContext context, Uri url) async {
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không thể mở ứng dụng. Vui lòng thử lại!'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Có lỗi xảy ra hoặc thiết bị không hỗ trợ.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Nền xám nhạt để làm nổi bật các Card
      appBar: AppBar(
        title: const Text(
          "Liên hệ & Hỗ trợ",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Hình ảnh minh họa (Icon lớn)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.support_agent_rounded, size: 80, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            const Text(
              "Chúng tôi có thể giúp gì cho bạn?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              "Hãy chọn một trong các phương thức dưới đây để kết nối với đội ngũ chăm sóc khách hàng của chúng tôi.",
              style: TextStyle(fontSize: 14, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Nút Gọi Hotline
            _buildContactCard(
              icon: Icons.phone_in_talk_outlined,
              title: "Gọi Hotline",
              subtitle: "1900 1234 - Phục vụ 24/7",
              color: Colors.green,
              onTap: () => _makePhoneCall(context, '19001234'), // Thay sđt ở đây
            ),
            const SizedBox(height: 15),

            // Nút Zalo
            _buildContactCard(
              icon: Icons.chat_bubble_outline,
              title: "Chat qua Zalo",
              subtitle: "Phản hồi nhanh chóng",
              color: Colors.blue,
              onTap: () => _openZalo(context, '0966774351'), // Thay sđt Zalo ở đây
            ),
            const SizedBox(height: 15),

            // Nút Email
            _buildContactCard(
              icon: Icons.email_outlined,
              title: "Gửi Email",
              subtitle: "support@beautybooking.com",
              color: Colors.orange,
              onTap: () => _sendEmail(context),
            ),
          ],
        ),
      ),
    );
  }

  // Widget tạo ra các thanh bấm nhìn giống Card rất đẹp mắt
  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 16),
          ],
        ),
      ),
    );
  }
}