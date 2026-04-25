import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/review.dart';
import '../repositories/review_repository.dart';

class GetShopReviewsUseCase implements UseCase<List<Review>, String> {
  GetShopReviewsUseCase(this._repository);
  final ReviewRepository _repository;

  @override
  Future<Either<Failure, List<Review>>> call(String shopId) =>
      _repository.getShopReviews(shopId);
}

class GetProductReviewsUseCase implements UseCase<List<Review>, String> {
  GetProductReviewsUseCase(this._repository);
  final ReviewRepository _repository;

  @override
  Future<Either<Failure, List<Review>>> call(String productId) =>
      _repository.getProductReviews(productId);
}

class SubmitReviewParams extends Equatable {
  const SubmitReviewParams({
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

class SubmitReviewUseCase implements UseCase<Review, SubmitReviewParams> {
  SubmitReviewUseCase(this._repository);
  final ReviewRepository _repository;

  @override
  Future<Either<Failure, Review>> call(SubmitReviewParams p) =>
      _repository.submitReview(
        targetId: p.targetId,
        targetType: p.targetType,
        rating: p.rating,
        comment: p.comment,
        orderId: p.orderId,
      );
}

class GetRatingSummaryParams extends Equatable {
  const GetRatingSummaryParams({
    required this.targetId,
    required this.targetType,
  });
  final String targetId;
  final String targetType;

  @override
  List<Object> get props => [targetId, targetType];
}

class GetRatingSummaryUseCase
    implements UseCase<RatingSummary, GetRatingSummaryParams> {
  GetRatingSummaryUseCase(this._repository);
  final ReviewRepository _repository;

  @override
  Future<Either<Failure, RatingSummary>> call(GetRatingSummaryParams p) =>
      _repository.getRatingSummary(
          targetId: p.targetId, targetType: p.targetType);
}
