class StoreDashboardModel {
  final String status;
  final StoreHeaderModel header;
  final StatisticsModel statistics;
  final CommissionModel commission;
  final BookingCountsModel bookingCounts;

  StoreDashboardModel({
    required this.status,
    required this.header,
    required this.statistics,
    required this.commission,
    required this.bookingCounts,
  });

  factory StoreDashboardModel.fromJson(Map<String, dynamic> json) {
    return StoreDashboardModel(
      status: json['status'] ?? 'pending',
      header: StoreHeaderModel.fromJson(json['header'] ?? {}),
      statistics: StatisticsModel.fromJson(json['statistics'] ?? {}),
      commission: CommissionModel.fromJson(json['commission'] ?? {}),
      bookingCounts: BookingCountsModel.fromJson(json['bookingCounts'] ?? {}),
    );
  }
}

class StoreHeaderModel {
  final String name;
  final String address;
  final String? logoUrl;

  StoreHeaderModel({
    required this.name,
    required this.address,
    this.logoUrl,
  });

  factory StoreHeaderModel.fromJson(Map<String, dynamic> json) {
    return StoreHeaderModel(
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      logoUrl: json['logoUrl'],
    );
  }
}

class StatisticsModel {
  final int totalCustomers;
  final int totalBookings;
  final double totalRevenue;

  StatisticsModel({
    required this.totalCustomers,
    required this.totalBookings,
    required this.totalRevenue,
  });

  factory StatisticsModel.fromJson(Map<String, dynamic> json) {
    return StatisticsModel(
      totalCustomers: json['totalCustomers'] ?? 0,
      totalBookings: json['totalBookings'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(), 
    );
  }
}

class CommissionModel {
  final double totalCommission;
  final double appUsageFee;
  final double totalWithdrawn;

  CommissionModel({
    required this.totalCommission,
    required this.appUsageFee,
    required this.totalWithdrawn,
  });

  factory CommissionModel.fromJson(Map<String, dynamic> json) {
    return CommissionModel(
      totalCommission: double.tryParse(json['totalCommission']?.toString() ?? '0') ?? 0.0,
      appUsageFee: double.tryParse(json['appUsageFee']?.toString() ?? '0') ?? 0.0,
      totalWithdrawn: double.tryParse(json['totalWithdrawn']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class BookingCountsModel {
  final int pending;
  final int confirmed;
  final int completed;
  final int cancelledByCustomer;

  BookingCountsModel({
    required this.pending,
    required this.confirmed,
    required this.completed,
    required this.cancelledByCustomer,
  });

  factory BookingCountsModel.fromJson(Map<String, dynamic> json) {
    return BookingCountsModel(
      pending: json['pending'] ?? 0,
      confirmed: json['confirmed'] ?? 0,
      completed: json['completed'] ?? 0,
      cancelledByCustomer: json['cancelledByCustomer'] ?? 0,
    );
  }
}