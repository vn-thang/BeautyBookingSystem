import 'package:intl/intl.dart';

class Formatters {
  static String formatCurrency(dynamic amount) {
    if (amount == null) return '0đ';
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return formatter.format(amount);
  }

  static String formatDateTime(DateTime? date) {
    if (date == null) return '';

    DateTime localDate;
    if (!date.isUtc) {
      DateTime forcedUtc = DateTime.utc(
        date.year, date.month, date.day, 
        date.hour, date.minute, date.second, 
        date.millisecond, date.microsecond
      );
      localDate = forcedUtc.toLocal(); 
    } else {
      localDate = date.toLocal();
    }

    return DateFormat('HH:mm dd/MM/yyyy').format(localDate);
  }

  static String formatDateOnly(DateTime? date) {
    if (date == null) return '';

    DateTime localDate;
    if (!date.isUtc) {
      DateTime forcedUtc = DateTime.utc(
        date.year, date.month, date.day, 
        date.hour, date.minute, date.second
      );
      localDate = forcedUtc.toLocal();
    } else {
      localDate = date.toLocal();
    }
    
    return DateFormat('dd/MM/yyyy').format(localDate);
  }
}