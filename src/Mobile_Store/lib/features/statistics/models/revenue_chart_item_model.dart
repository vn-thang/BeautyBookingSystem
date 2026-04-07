class RevenueChartItemModel {
  final String dateLabel;
  final double totalRevenue;
  final int totalBookings;

  RevenueChartItemModel({
    required this.dateLabel,
    required this.totalRevenue,
    required this.totalBookings,
  });

  factory RevenueChartItemModel.fromJson(Map<String, dynamic> json) {
    return RevenueChartItemModel(
      dateLabel: json['dateLabel'] ?? '',
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(), 
      totalBookings: json['totalBookings'] ?? 0,
    );
  }
}