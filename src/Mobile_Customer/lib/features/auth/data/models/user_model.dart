import '../../domain/entities/user.dart';

class UserModel extends User {

  UserModel({
    required super.id,
    required super.email,
    super.name,
    super.phone,
    super.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {

    return UserModel(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      name: json['fullName'] ?? json['name'],
      phone: json['phone'],
      avatarUrl: json['avatarUrl'],
    );

  }
}