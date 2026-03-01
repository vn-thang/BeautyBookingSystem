import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("Notification Page")),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }
}