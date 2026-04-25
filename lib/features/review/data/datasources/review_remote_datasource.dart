import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/review.dart';
import '../models/review_model.dart';

abstract class ReviewRemoteDataSource {
  Future<List<ReviewModel>> getShopReviews(String shopId);
  Future<List<ReviewModel>> getProductReviews(String productId);
  Future<ReviewModel> submitReview({
    required String targetId,
    required String targetType,
    required int rating,
    String? comment,
    String? orderId,
  });
  Future<RatingSummary> getRatingSummary({
    required String targetId,
    required String targetType,
  });
}

class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  ReviewRemoteDataSourceImpl(this._apiClient);
  final ApiClient _apiClient;

  @override
  Future<List<ReviewModel>> getShopReviews(String shopId) async {
    final path = ApiEndpoints.replacePathParam(
        ApiEndpoints.reviewsShop, 'shop_id', shopId);
    final data = await _apiClient.get(path);
    final list = data is List
        ? data as List<dynamic>
        : (data['reviews'] as List<dynamic>? ?? []);
    return list
        .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ReviewModel>> getProductReviews(String productId) async {
    final data = await _apiClient.get(ApiEndpoints.reviewsList,
        queryParams: {'product_id': productId});
    final list = data is List
        ? data as List<dynamic>
        : (data['reviews'] as List<dynamic>? ?? []);
    return list
        .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ReviewModel> submitReview({
    required String targetId,
    required String targetType,
    required int rating,
    String? comment,
    String? orderId,
  }) async {
    final body = <String, dynamic>{
      'target_id': targetId,
      'target_type': targetType,
      'rating': rating,
      if (comment != null) 'comment': comment,
      if (orderId != null) 'order_id': orderId,
    };
    final data = await _apiClient.post(ApiEndpoints.reviewsCreate, body);
    return ReviewModel.fromJson(data);
  }

  @override
  Future<RatingSummary> getRatingSummary({
    required String targetId,
    required String targetType,
  }) async {
    final data = await _apiClient.get(ApiEndpoints.reviewsList,
        queryParams: {'target_id': targetId, 'target_type': targetType, 'summary': 'true'});
    return RatingSummary(
      average: (data['average'] as num?)?.toDouble() ?? 0.0,
      total: data['total'] as int? ?? 0,
      distribution: {},
    );
  }
}
