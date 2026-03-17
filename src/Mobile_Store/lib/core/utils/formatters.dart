import 'package:intl/intl.dart';

class Formatters {
  // Chỉ khởi tạo một lần duy nhất, gọi ở bất kỳ đâu trong app cũng không tốn RAM
  static final currency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
  static final dateTime = DateFormat('dd/MM/yyyy HH:mm');
}