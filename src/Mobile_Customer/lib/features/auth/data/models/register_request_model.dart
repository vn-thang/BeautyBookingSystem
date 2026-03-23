class RegisterRequestModel {
  final String fullName;
  final String phone;
  final String email;
  final String password;

  RegisterRequestModel({
    required this.fullName,
    required this.phone,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      "fullName": fullName,
      "phone": phone,
      "email": email,
      "password": password,
    };
  }
}