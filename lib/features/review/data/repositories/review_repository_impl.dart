import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';
import '../datasources/review_remote_datasource.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  ReviewRepositoryImpl(this._remoteDataSource);
  final ReviewRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<Review>>> getShopReviews(String shopId) async {
    try {
      final list = await _remoteDataSource.getShopReviews(shopId);
      return Right(list);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Review>>> getProductReviews(
      String productId) async {
    try {
      final list = await _remoteDataSource.getProductReviews(productId);
      return Right(list);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Review>> submitReview({
    required String targetId,
    required String targetType,
    required int rating,
    String? comment,
    String? orderId,
  }) async {
    try {
      final review = await _remoteDataSource.submitReview(
        targetId: targetId,
        targetType: targetType,
        rating: rating,
        comment: comment,
        orderId: orderId,
      );
      return Right(review);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, RatingSummary>> getRatingSummary({
    required String targetId,
    required String targetType,
  }) async {
    try {
      final summary = await _remoteDataSource.getRatingSummary(
          targetId: targetId, targetType: targetType);
      return Right(summary);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
