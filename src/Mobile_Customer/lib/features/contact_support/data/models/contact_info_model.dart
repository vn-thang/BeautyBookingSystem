import '../../domain/entities/contact_info.dart';

class ContactInfoModel extends ContactInfo {
  const ContactInfoModel({
    required super.hotline,
    required super.email,
  });

  factory ContactInfoModel.fromJson(Map<String, dynamic> json) {
    return ContactInfoModel(
      hotline: (json['Hotline'] ?? 'Đang cập nhật').toString(),
      email: (json['Email'] ?? 'Đang cập nhật').toString(),
    );
  }
}
