class StoreReviewModel {
  final int id;
  final int bookingId;
  final String? customerName;
  final String? customerAvatar;
  final int rating;
  final String? comment;
  String? reply; // Không để final vì có thể update sau khi phản hồi
  final bool isHidden;

  StoreReviewModel({
    required this.id,
    required this.bookingId,
    this.customerName,
    this.customerAvatar,
    required this.rating,
    this.comment,
    this.reply,
    this.isHidden = false,
  });

  factory StoreReviewModel.fromJson(dynamic json) {
    return StoreReviewModel(
      id: json['id'] ?? 0,
      bookingId: json['bookingId'] ?? 0,
      customerName: json['customerName'],
      customerAvatar: json['customerAvatar'],
      rating: json['rating'] ?? 0,
      comment: json['comment'],
      reply: json['reply'],
      isHidden: json['isHidden'] ?? false,
    );
  }
}