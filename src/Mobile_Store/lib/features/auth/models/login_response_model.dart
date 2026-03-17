class LoginResponseModel {
  final String accessToken;
  final String refreshToken;
  final String role;
  final String? storeStatus;

  LoginResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.role,
    this.storeStatus,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      accessToken: json["accessToken"],
      refreshToken: json["refreshToken"],
      role: json['role'] ?? '',
      storeStatus: json['storeStatus'],
    );
  }
}