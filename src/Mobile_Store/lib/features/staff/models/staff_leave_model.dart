class StaffLeaveModel {
  final int id;
  final int staffId;
  final DateTime fromDate;
  final DateTime toDate;
  final String? reason;

  StaffLeaveModel({
    required this.id,
    required this.staffId,
    required this.fromDate,
    required this.toDate,
    this.reason,
  });

  factory StaffLeaveModel.fromJson(Map<String, dynamic> json) {
    return StaffLeaveModel(
      id: json['id'] ?? 0,
      staffId: json['staffId'] ?? 0,
      fromDate: DateTime.parse(json['fromDate']),
      toDate: DateTime.parse(json['toDate']),
      reason: json['reason'],
    );
  }
}