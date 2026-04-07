class CustomerListModel {
  final int customerId;
  final String fullName;
  final String phone;
  final String? avatarUrl;
  final int totalVisits;
  final double totalSpent;

  CustomerListModel({
    required this.customerId,
    required this.fullName,
    required this.phone,
    this.avatarUrl,
    required this.totalVisits,
    required this.totalSpent,
  });

  factory CustomerListModel.fromJson(Map<String, dynamic> json) {
    return CustomerListModel(
      customerId: json['customerId'] ?? 0,
      fullName: json['fullName'] ?? '',
      phone: json['phone'] ?? '',
      avatarUrl: json['avatarUrl'],
      totalVisits: json['totalVisits'] ?? 0,
      totalSpent: (json['totalSpent'] ?? 0).toDouble(), 
    );
  }
}