class UpdateProfileRequestModel {
  final String fullName;
  final String? email;
  final String? avatarUrl;

  UpdateProfileRequestModel({
    required this.fullName,
    this.email,
    this.avatarUrl,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      "fullName": fullName,
    };

    if (email != null && email!.trim().isNotEmpty) {
      data["email"] = email!.trim();
    }

    if (avatarUrl != null && avatarUrl!.trim().isNotEmpty) {
      data["avatarUrl"] = avatarUrl!.trim();
    }

    return data;
  }
}
