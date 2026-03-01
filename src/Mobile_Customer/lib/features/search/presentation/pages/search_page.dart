import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tìm kiếm")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: const [
            TextField(
              decoration: InputDecoration(prefixIcon: Icon(Icons.search), hintText: "Tìm theo tên cửa hàng, dịch vụ..."),
            ),
            SizedBox(height: 20),
            Text("Kết quả tìm kiếm sẽ hiển thị ở đây"),
          ],
        ),
      ),
          bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }
}