/// Mock implementation of Product Remote Data Source for testing without backend.
library;

import '../../features/product/data/datasources/product_remote_datasource.dart';
import '../../features/shop/domain/entities/product.dart';
import 'mock_data.dart';

class MockProductRemoteDataSource implements ProductRemoteDataSource {
  @override
  Future<Product> getProductById(String id) async {
    await MockData.simulateDelay();
    final product = MockData.getProductById(id);
    if (product == null) throw Exception('Product not found: $id');
    return product;
  }
}
