import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../shop/domain/entities/product.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_local_datasource.dart';
import '../models/cart_item.dart';

class CartRepositoryImpl implements CartRepository {
  CartRepositoryImpl(this._localDataSource);
  final CartLocalDataSource _localDataSource;

  @override
  Future<Either<Failure, List<CartItemModel>>> getCart() async {
    try {
      final items = await _localDataSource.getCart();
      return Right(items);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addItem(Product product, int quantity) async {
    try {
      final items = await _localDataSource.getCart();
      final current = List<CartItemModel>.from(items);
      final idx = current.indexWhere((i) => i.product.id == product.id);
      if (idx >= 0) {
        current[idx] = CartItemModel(
            product: current[idx].product,
            quantity: current[idx].quantity + quantity);
      } else {
        current.add(CartItemModel(product: product, quantity: quantity));
      }
      await _localDataSource.saveCart(current);
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeItem(String productId) async {
    try {
      final items = await _localDataSource.getCart();
      final updated = items.where((i) => i.product.id != productId).toList();
      await _localDataSource.saveCart(updated);
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateQuantity(
      String productId, int quantity) async {
    try {
      final items = await _localDataSource.getCart();
      final updated = List<CartItemModel>.from(items);
      final idx = updated.indexWhere((i) => i.product.id == productId);
      if (idx >= 0) {
        if (quantity <= 0) {
          updated.removeAt(idx);
        } else {
          updated[idx] =
              CartItemModel(product: updated[idx].product, quantity: quantity);
        }
      }
      await _localDataSource.saveCart(updated);
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearCart() async {
    try {
      await _localDataSource.saveCart(const []);
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
