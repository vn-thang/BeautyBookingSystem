class ContactInfoModel {
  final String hotline;
  final String email;
  final String zalo;

  ContactInfoModel({
    required this.hotline,
    required this.email,
    required this.zalo,
  });

  factory ContactInfoModel.fromJson(Map<String, dynamic> json) {
    return ContactInfoModel(
      hotline: json['hotline'] ?? json['Hotline'] ?? 'Đang cập nhật',
      email: json['email'] ?? json['Email'] ?? 'Đang cập nhật',
      zalo: json['zalo'] ?? json['Zalo'] ?? json['hotline'] ?? json['Hotline'] ?? 'Đang cập nhật', 
    );
  }
}