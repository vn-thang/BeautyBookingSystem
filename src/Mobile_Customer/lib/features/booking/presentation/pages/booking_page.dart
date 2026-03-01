import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';

class BookingPage extends StatelessWidget {
  const BookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đặt lịch")),
      body: const Center(child: Text("Giao diện Đặt lịch")),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }
}