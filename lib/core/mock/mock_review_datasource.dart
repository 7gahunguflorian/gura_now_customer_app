/// Mock implementation of Review Remote Data Source.
library;

import '../../features/review/data/datasources/review_remote_datasource.dart';
import '../../features/review/data/models/review_model.dart';
import '../../features/review/domain/entities/review.dart';
import 'mock_data.dart';

class MockReviewRemoteDataSource implements ReviewRemoteDataSource {
  @override
  Future<List<ReviewModel>> getShopReviews(String shopId) async {
    await MockData.simulateDelay();
    return MockData.getShopReviews(shopId);
  }

  @override
  Future<List<ReviewModel>> getProductReviews(String productId) async {
    await MockData.simulateDelay();
    return MockData.getProductReviews(productId);
  }

  @override
  Future<ReviewModel> submitReview({
    required String targetId,
    required String targetType,
    required int rating,
    String? comment,
    String? orderId,
  }) async {
    await MockData.simulateDelay();
    final review = ReviewModel(
      id: 'rev-${DateTime.now().millisecondsSinceEpoch}',
      userId: 'user-1',
      userName: 'Jean Baptiste',
      rating: rating,
      comment: comment,
      shopId: targetType == 'shop' ? targetId : null,
      productId: targetType == 'product' ? targetId : null,
      orderId: orderId,
      createdAt: DateTime.now(),
    );
    MockData.reviews.add(review);
    return review;
  }

  @override
  Future<RatingSummary> getRatingSummary({
    required String targetId,
    required String targetType,
  }) async {
    await MockData.simulateDelay();
    final list = targetType == 'shop'
        ? MockData.getShopReviews(targetId)
        : MockData.getProductReviews(targetId);
    if (list.isEmpty) {
      return const RatingSummary(average: 0, total: 0, distribution: {});
    }
    final avg = list.map((r) => r.rating).reduce((a, b) => a + b) / list.length;
    return RatingSummary(average: avg, total: list.length, distribution: {});
  }
}
