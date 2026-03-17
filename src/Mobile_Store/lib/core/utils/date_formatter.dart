class DateFormatter {
  // Hàm này dùng static để gọi thẳng từ tên class mà không cần khởi tạo
  static String formatDateTime(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} '
           'lúc ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}