import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../shop/domain/entities/product.dart';
import '../../data/models/cart_item.dart';

abstract class CartRepository {
  Future<Either<Failure, List<CartItemModel>>> getCart();
  Future<Either<Failure, void>> addItem(Product product, int quantity);
  Future<Either<Failure, void>> removeItem(String productId);
  Future<Either<Failure, void>> updateQuantity(String productId, int quantity);
  Future<Either<Failure, void>> clearCart();
}
