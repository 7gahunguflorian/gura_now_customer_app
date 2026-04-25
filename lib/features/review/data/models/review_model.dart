import '../../domain/entities/review.dart';

class ReviewModel extends Review {
  const ReviewModel({
    required super.id,
    required super.userId,
    required super.userName,
    required super.rating,
    super.comment,
    super.shopId,
    super.productId,
    super.orderId,
    required super.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        userName: json['user_name'] as String? ?? 'Utilisateur',
        rating: json['rating'] as int,
        comment: json['comment'] as String?,
        shopId: json['shop_id'] as String?,
        productId: json['product_id'] as String?,
        orderId: json['order_id'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'user_name': userName,
        'rating': rating,
        'comment': comment,
        'shop_id': shopId,
        'product_id': productId,
        'order_id': orderId,
        'created_at': createdAt.toIso8601String(),
      };
}
