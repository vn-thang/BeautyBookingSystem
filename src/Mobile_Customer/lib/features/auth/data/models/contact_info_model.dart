class ContactInfoModel {
  final String hotline;
  final String email;

  const ContactInfoModel({
    required this.hotline,
    required this.email,
  });

  factory ContactInfoModel.fromJson(Map<String, dynamic> json) {
    return ContactInfoModel(
      hotline: (json['Hotline'] ?? 'Đang cập nhật').toString(),
      email: (json['Email'] ?? 'Đang cập nhật').toString(),
    );
  }

  factory ContactInfoModel.empty() {
    return const ContactInfoModel(
      hotline: 'Đang cập nhật',
      email: 'Đang cập nhật',
    );
  }
}
