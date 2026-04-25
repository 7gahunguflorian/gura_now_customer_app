part of 'review_bloc.dart';

abstract class ReviewEvent extends Equatable {
  const ReviewEvent();
  @override
  List<Object?> get props => [];
}

class ReviewShopRequested extends ReviewEvent {
  const ReviewShopRequested(this.shopId);
  final String shopId;
  @override
  List<Object?> get props => [shopId];
}

class ReviewProductRequested extends ReviewEvent {
  const ReviewProductRequested(this.productId);
  final String productId;
  @override
  List<Object?> get props => [productId];
}

class ReviewSubmitRequested extends ReviewEvent {
  const ReviewSubmitRequested({
    required this.targetId,
    required this.targetType,
    required this.rating,
    this.comment,
    this.orderId,
  });
  final String targetId;
  final String targetType;
  final int rating;
  final String? comment;
  final String? orderId;

  @override
  List<Object?> get props => [targetId, targetType, rating, comment, orderId];
}

class ReviewSummaryRequested extends ReviewEvent {
  const ReviewSummaryRequested({
    required this.targetId,
    required this.targetType,
  });
  final String targetId;
  final String targetType;

  @override
  List<Object?> get props => [targetId, targetType];
}
