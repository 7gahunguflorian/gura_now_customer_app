import 'package:equatable/equatable.dart';

class Review extends Equatable {
  const Review({
    required this.id,
    required this.userId,
    required this.userName,
    required this.rating,
    this.comment,
    this.shopId,
    this.productId,
    this.orderId,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String userName;
  final int rating;
  final String? comment;
  final String? shopId;
  final String? productId;
  final String? orderId;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
        id, userId, userName, rating, comment, shopId, productId, orderId,
        createdAt
      ];
}

class RatingSummary extends Equatable {
  const RatingSummary({
    required this.average,
    required this.total,
    required this.distribution,
  });

  final double average;
  final int total;
  final Map<int, int> distribution;

  @override
  List<Object?> get props => [average, total, distribution];
}
