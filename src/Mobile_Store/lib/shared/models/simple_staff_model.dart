class SimpleStaffModel {
  final int id;
  final String fullName; 

  SimpleStaffModel({
    required this.id,
    required this.fullName,
  });

  factory SimpleStaffModel.fromJson(Map<String, dynamic> json) {
    return SimpleStaffModel(
      id: json['id'] ?? 0,
      fullName: json['fullName'] ?? json['name'] ?? 'Chưa cập nhật',
    );
  }
}