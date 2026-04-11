class TopPerformanceItemModel {
  final int id;
  final String name;
  final int count;
  final double revenue;

  TopPerformanceItemModel({
    required this.id,
    required this.name,
    required this.count,
    required this.revenue,
  });

  factory TopPerformanceItemModel.fromJson(Map<String, dynamic> json) {
    return TopPerformanceItemModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      count: json['count'] ?? 0,
      revenue: (json['revenue'] ?? 0).toDouble(),
    );
  }
}