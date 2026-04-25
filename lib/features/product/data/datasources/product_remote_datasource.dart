import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../shop/domain/entities/product.dart';

abstract class ProductRemoteDataSource {
  Future<Product> getProductById(String id);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  ProductRemoteDataSourceImpl(this._apiClient);
  final ApiClient _apiClient;

  @override
  Future<Product> getProductById(String id) async {
    final path = ApiEndpoints.replacePathParam(
        ApiEndpoints.productsDetail, 'product_id', id);
    final data = await _apiClient.get(path);
    return Product.fromJson(data);
  }
}
