class StaffModel {
  final int id;
  final int storeId;
  final String fullName;
  final String? avatarUrl;
  final String position;
  final bool isActive;

  StaffModel({
    required this.id,
    required this.storeId,
    required this.fullName,
    this.avatarUrl,
    required this.position,
    required this.isActive,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      id: json['id'] ?? 0,
      storeId: json['storeId'] ?? 0,
      fullName: json['fullName'] ?? '',
      avatarUrl: json['avatarUrl'],
      position: json['position'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }
}