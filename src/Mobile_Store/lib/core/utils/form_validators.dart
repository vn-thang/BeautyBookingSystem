
class FormValidators {
  // 1. Kiểm tra bắt buộc nhập chung chung
  static String? requiredField(String? value, [String message = 'Trường này không được để trống']) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  // 2. Validate Email
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Vui lòng nhập email';
    final emailRegex = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) return 'Email không hợp lệ';
    return null;
  }

  // 3. Validate Số điện thoại (Việt Nam)
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Vui lòng nhập số điện thoại';
    final phoneRegex = RegExp(r'^(0|\+84)[0-9]{8,9}$');
    if (!phoneRegex.hasMatch(value.trim())) return 'Số điện thoại không hợp lệ';
    return null;
  }

  // 4. Validate Email HOẶC Số điện thoại (Dùng riêng cho Login)
  static String? emailOrPhone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Vui lòng nhập email hoặc số điện thoại';
    final trimmed = value.trim();
    final emailRegex = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$');
    final phoneRegex = RegExp(r'^(0|\+84)[0-9]{8,9}$');

    if (!emailRegex.hasMatch(trimmed) && !phoneRegex.hasMatch(trimmed)) {
      return 'Thông tin không hợp lệ';
    }
    return null;
  }

  // 5. Validate Mật khẩu (Có thể tùy chỉnh độ dài tối thiểu)
  static String? password(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu';
    if (value.length < minLength) return 'Mật khẩu phải có ít nhất $minLength ký tự';
    return null;
  }

  // 6. Validate Xác nhận mật khẩu
  static String? confirmPassword(String? value, String originalPassword) {
    if (value == null || value.isEmpty) return 'Vui lòng xác nhận mật khẩu';
    if (value != originalPassword) return 'Mật khẩu không khớp';
    return null;
  }
}