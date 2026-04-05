import '../../domain/entities/available_staff.dart';

class AvailableStaffModel extends AvailableStaff {
  AvailableStaffModel({
    required int staffId,
    required String name,
    required String avatarUrl,
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
