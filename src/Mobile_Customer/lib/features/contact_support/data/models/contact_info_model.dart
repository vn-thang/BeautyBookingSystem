import '../../domain/entities/contact_info.dart';

class ContactInfoModel extends ContactInfo {
  const ContactInfoModel({
    required super.hotline,
    required super.email,
  });

  factory ContactInfoModel.fromJson(Map<String, dynamic> json) {
    final hotline =
        (json['hotline'] ?? json['Hotline'] ?? '').toString().trim();
    final email = (json['email'] ?? json['Email'] ?? '').toString().trim();

    return ContactInfoModel(
      hotline: hotline.isNotEmpty ? hotline : 'Đang cập nhật',
      email: email.isNotEmpty ? email : 'Đang cập nhật',
    );
  }
}
