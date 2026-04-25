import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/review.dart';

abstract class ReviewRepository {
  Future<Either<Failure, List<Review>>> getShopReviews(String shopId);
  Future<Either<Failure, List<Review>>> getProductReviews(String productId);
  Future<Either<Failure, Review>> submitReview({
    required String targetId,
    required String targetType,
    required int rating,
    String? comment,
    String? orderId,
  });
  Future<Either<Failure, RatingSummary>> getRatingSummary({
    required String targetId,
    required String targetType,
  });
}
