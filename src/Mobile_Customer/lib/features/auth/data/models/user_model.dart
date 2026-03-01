import '../../domain/entities/user_entity.dart';

class UserModel {
  final int id;
  final String fullName;
  final String phone;
  final String? email;
  final int role;
  final int status;
  final bool isPhoneVerified;

  UserModel({
    required this.id,
    required this.fullName,
    required this.phone,
    this.email,
    required this.role,
    required this.status,
    required this.isPhoneVerified,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      fullName: json['fullName'],
      phone: json['phone'],
      email: json['email'],
      role: json['role'],
      status: json['status'],
      isPhoneVerified: json['isPhoneVerified'],
    );
  }

  /// 🔥 THÊM CÁI NÀY
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      fullName: fullName,
      phone: phone,
      email: email,
      role: role,
      status: status,
      isPhoneVerified: isPhoneVerified,
    );
  }
}