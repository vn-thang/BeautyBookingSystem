class UserEntity {
  final int id;
  final String fullName;
  final String phone;
  final String? email;
  final int role;
  final int status;
  final bool isPhoneVerified;

  const UserEntity({
    required this.id,
    required this.fullName,
    required this.phone,
    this.email,
    required this.role,
    required this.status,
    required this.isPhoneVerified,
  });

  /// Optional: tiện cho debug
  @override
  String toString() {
    return '''
UserEntity(
  id: $id,
  fullName: $fullName,
  phone: $phone,
  email: $email,
  role: $role,
  status: $status,
  isPhoneVerified: $isPhoneVerified
)
''';
  }

  /// Optional: so sánh object (rất nên có nếu dùng Bloc)
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          fullName == other.fullName &&
          phone == other.phone &&
          email == other.email &&
          role == other.role &&
          status == other.status &&
          isPhoneVerified == other.isPhoneVerified;

  @override
  int get hashCode =>
      id.hashCode ^
      fullName.hashCode ^
      phone.hashCode ^
      email.hashCode ^
      role.hashCode ^
      status.hashCode ^
      isPhoneVerified.hashCode;
}