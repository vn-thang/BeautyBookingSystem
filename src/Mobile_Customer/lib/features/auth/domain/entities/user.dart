class User {
  final int id;
  final String email;
  final String? name;
  final String? phone;
  final String? avatarUrl;

  User({
    required this.id,
    required this.email,
    this.name,
    this.phone,
    this.avatarUrl,
  });
}