/// Mock implementation of Shop Remote Data Source for testing without backend.
library;

import '../../features/shop/data/datasources/shop_remote_datasource.dart';
import '../../features/shop/data/models/shop_model.dart';
import '../../features/shop/domain/entities/product.dart';
import 'mock_data.dart';

/// Mock shop data source that uses local mock data instead of API calls.
class MockShopRemoteDataSource implements ShopRemoteDataSource {
  @override
  Future<List<ShopModel>> getShops({
    String? category,
    int limit = 20,
    int offset = 0,
  }) async {
    // Simulate network delay
    await MockData.simulateDelay();

    return MockData.getShops(
      category: category,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<ShopModel> getShopDetail(String id) async {
    await MockData.simulateDelay();
    final shop = MockData.getShopById(id);
    if (shop == null) throw Exception('Shop not found');
    return shop;
  }

  @override
  Future<List<Product>> getShopProducts(String shopId) async {
    await MockData.simulateDelay();
    return MockData.getProductsByShopId(shopId);
  }
}
