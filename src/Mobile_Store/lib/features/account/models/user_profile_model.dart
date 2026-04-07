class UserProfileModel {
  final int id;
  final String fullName;
  final String phone;
  final String? email;
  final String? avatarUrl;
  final String role;
  final String status;

  UserProfileModel({
    required this.id,
    required this.fullName,
    required this.phone,
    this.email,
    this.avatarUrl,
    required this.role,
    required this.status,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] ?? 0,
      fullName: json['fullName'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
      avatarUrl: json['avatarUrl'],
      role: json['role'] ?? '',
      status: json['status'] ?? '',
    );
  }
}