import 'package:intl/intl.dart';

class Formatters {
  static final currency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
  static final dateTime = DateFormat('dd/MM/yyyy HH:mm');
}