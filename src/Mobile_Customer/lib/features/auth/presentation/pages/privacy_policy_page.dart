import 'package:flutter/material.dart';

import '../../../../core/screens/custom_webview_screen.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomWebViewScreen(
      title: 'Chính sách bảo mật',
      url: 'http://localhost:5173/chinh-sach-chung',
    );
  }
}
