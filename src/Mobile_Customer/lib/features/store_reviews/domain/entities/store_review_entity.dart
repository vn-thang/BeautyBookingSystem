class ReviewCustomerEntity {
  final int id;
  final String fullName;
  final String? avatarUrl;
  final String? email;
  final String? phone;
  final String role;
  final String status;
  final bool isPhoneVerified;
  final DateTime createdAt;

  ReviewCustomerEntity({
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
}

class StoreReviewEntity {
  final int id;
  final int bookingId;
  final int customerId;
  final int storeId;
  final String storeName;
  final ReviewCustomerEntity customer;
  final int rating;
  final String? comment;
  final String? reply;
  final bool isHidden;
  final DateTime createdAt;

  StoreReviewEntity({
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
}

class PagedStoreReviewEntity {
  final int page;
  final int pageSize;
  final int total;
  final List<StoreReviewEntity> items;

  PagedStoreReviewEntity({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.items,
  });

  bool get hasMore => page * pageSize < total;
}
