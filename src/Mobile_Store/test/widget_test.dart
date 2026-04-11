import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_store/main.dart';

void main() {
  testWidgets('App starts successfully', (WidgetTester tester) async {
    // Đổi MyApp() thành StoreAdminApp() cho khớp với tên mới
    await tester.pumpWidget(const StoreAdminApp(initialRoute: '/login'));
  });
}