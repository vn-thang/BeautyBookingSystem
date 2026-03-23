import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lịch sử")),
      body: const Center(child: Text("Lịch sử đặt dịch vụ của bạn")),
    );
  }
}