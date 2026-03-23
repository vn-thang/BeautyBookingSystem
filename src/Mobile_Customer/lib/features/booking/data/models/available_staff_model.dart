import '../../domain/entities/available_staff.dart';

class AvailableStaffModel extends AvailableStaff {
  final String avatarUrl;

  AvailableStaffModel({
    required int staffId,
    required String name,
    required this.avatarUrl,
  }) : super(
          staffId: staffId,
          name: name,
          avatarUrl: avatarUrl, 
        );

  factory AvailableStaffModel.fromJson(Map<String, dynamic> json) {
    return AvailableStaffModel(
      staffId: json['id'],
      name: json['name'],
      avatarUrl: json['avatarUrl'] ?? "",
    );
  }
}