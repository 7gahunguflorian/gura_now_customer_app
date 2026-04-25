import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../shop/domain/entities/product.dart';
import '../models/shop_model.dart';

abstract class ShopRemoteDataSource {
  Future<List<ShopModel>> getShops({
    String? category,
    int limit = 20,
    int offset = 0,
  });
  Future<ShopModel> getShopDetail(String id);
  Future<List<Product>> getShopProducts(String shopId);
}

class ShopRemoteDataSourceImpl implements ShopRemoteDataSource {
  ShopRemoteDataSourceImpl(this._apiClient);
  final ApiClient _apiClient;

  @override
  Future<List<ShopModel>> getShops({
    String? category,
    int limit = 20,
    int offset = 0,
  }) async {
    final data = await _apiClient.get(
      ApiEndpoints.shopsList,
      queryParams: {
        if (category != null) 'category': category,
        'limit': limit,
        'offset': offset,
      },
    );
    final shops = data is List
        ? data as List<dynamic>
        : (data['shops'] as List<dynamic>? ?? <dynamic>[]);
    return shops
        .map((json) => ShopModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ShopModel> getShopDetail(String id) async {
    final path =
        ApiEndpoints.replacePathParam(ApiEndpoints.shopsDetail, 'shop_id', id);
    final data = await _apiClient.get(path);
    return ShopModel.fromJson(data);
  }

  @override
  Future<List<Product>> getShopProducts(String shopId) async {
    final data = await _apiClient.get(
      ApiEndpoints.productsList,
      queryParams: {'shop_id': shopId},
    );
    final list = data is List
        ? data as List<dynamic>
        : (data['products'] as List<dynamic>? ?? <dynamic>[]);
    return list
        .map((json) => Product.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
