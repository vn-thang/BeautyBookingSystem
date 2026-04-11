import '../../domain/entities/store_review_entity.dart';

class ReviewCustomerModel {
  final int id;
  final String fullName;
  final String? avatarUrl;
  final String? email;
  final String? phone;
  final String role;
  final String status;
  final bool isPhoneVerified;
  final DateTime createdAt;

  ReviewCustomerModel({
    required this.id,
    required this.fullName,
    required this.avatarUrl,
    required this.email,
    required this.phone,
    required this.role,
    required this.status,
    required this.isPhoneVerified,
    required this.createdAt,
  });

  factory ReviewCustomerModel.fromJson(Map<String, dynamic> json) {
    return ReviewCustomerModel(
      id: _int(json['id']),
      fullName: json['fullName']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      role: json['role']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      isPhoneVerified: json['isPhoneVerified'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  ReviewCustomerEntity toEntity() {
    return ReviewCustomerEntity(
      id: id,
      fullName: fullName,
      avatarUrl: avatarUrl,
      email: email,
      phone: phone,
      role: role,
      status: status,
      isPhoneVerified: isPhoneVerified,
      createdAt: createdAt,
    );
  }

  static int _int(dynamic x) => x is int ? x : int.tryParse('$x') ?? 0;
}

class StoreReviewModel {
  final int id;
  final int bookingId;
  final int customerId;
  final int storeId;
  final String storeName;
  final ReviewCustomerModel customer;
  final int rating;
  final String? comment;
  final String? reply;
  final bool isHidden;
  final DateTime createdAt;

  StoreReviewModel({
    required this.id,
    required this.bookingId,
    required this.customerId,
    required this.storeId,
    required this.storeName,
    required this.customer,
    required this.rating,
    required this.comment,
    required this.reply,
    required this.isHidden,
    required this.createdAt,
  });

  factory StoreReviewModel.fromJson(Map<String, dynamic> json) {
    return StoreReviewModel(
      id: _int(json['id']),
      bookingId: _int(json['bookingId']),
      customerId: _int(json['customerId']),
      storeId: _int(json['storeId']),
      storeName: json['storeName']?.toString() ?? '',
      customer: ReviewCustomerModel.fromJson(
        (json['customer'] as Map<String, dynamic>?) ?? const {},
      ),
      rating: _int(json['rating']),
      comment: json['comment']?.toString(),
      reply: json['reply']?.toString(),
      isHidden: json['isHidden'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  StoreReviewEntity toEntity() {
    return StoreReviewEntity(
      id: id,
      bookingId: bookingId,
      customerId: customerId,
      storeId: storeId,
      storeName: storeName,
      customer: customer.toEntity(),
      rating: rating,
      comment: comment,
      reply: reply,
      isHidden: isHidden,
      createdAt: createdAt,
    );
  }

  static int _int(dynamic x) => x is int ? x : int.tryParse('$x') ?? 0;
}

class PagedStoreReviewModel {
  final int page;
  final int pageSize;
  final int total;
  final List<StoreReviewModel> items;

  PagedStoreReviewModel({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.items,
  });

  factory PagedStoreReviewModel.fromJson(Map<String, dynamic> json) {
    return PagedStoreReviewModel(
      page: StoreReviewModel._int(json['page']),
      pageSize: StoreReviewModel._int(json['pageSize']),
      total: StoreReviewModel._int(json['total']),
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => StoreReviewModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  PagedStoreReviewEntity toEntity() {
    return PagedStoreReviewEntity(
      page: page,
      pageSize: pageSize,
      total: total,
      items: items.map((e) => e.toEntity()).toList(),
    );
  }
}
