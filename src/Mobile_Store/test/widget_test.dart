import 'package:flutter_test/flutter_test.dart';
import '../lib/main.dart'; // Trỏ về file main.dart của bạn

void main() {
  testWidgets('App starts successfully', (WidgetTester tester) async {
    // Đổi MyApp() thành StoreAdminApp() cho khớp với tên mới
    await tester.pumpWidget(const StoreAdminApp());
  });
}