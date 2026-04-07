import '../../domain/entities/review_entity.dart';

class ReviewModel extends ReviewEntity {
  ReviewModel({
    required super.id,
    required super.bookingId,
    required super.customerId,
    required super.storeId,
    required super.storeName,
    required super.rating,
    super.comment,
    super.reply,
    required super.isHidden,
    required super.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      bookingId: (json['bookingId'] as num?)?.toInt() ?? 0,
      customerId: (json['customerId'] as num?)?.toInt() ?? 0,
      storeId: (json['storeId'] as num?)?.toInt() ?? 0,
      storeName: (json['storeName'] as String?) ?? '',
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      comment: json['comment'] as String?,
      reply: json['reply'] as String?,
      isHidden: json['isHidden'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
