class ReviewEntity {
  final int id;
  final int bookingId;
  final int customerId;
  final int storeId;
  final String storeName;
  final int rating;
  final String? comment;
  final String? reply;
  final bool isHidden;
  final DateTime createdAt;

  ReviewEntity({
    required this.id,
    required this.bookingId,
    required this.customerId,
    required this.storeId,
    required this.storeName,
    required this.rating,
    this.comment,
    this.reply,
    required this.isHidden,
    required this.createdAt,
  });
}
