import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../shop/domain/entities/product.dart';
import '../../data/models/cart_item.dart';
import '../repositories/cart_repository.dart';

class GetCartUseCase implements UseCase<List<CartItemModel>, NoParams> {
  GetCartUseCase(this._repository);
  final CartRepository _repository;

  @override
  Future<Either<Failure, List<CartItemModel>>> call(NoParams _) =>
      _repository.getCart();
}

class AddToCartParams extends Equatable {
  const AddToCartParams(this.product, this.quantity);
  final Product product;
  final int quantity;

  @override
  List<Object> get props => [product, quantity];
}

class AddToCartUseCase implements UseCase<void, AddToCartParams> {
  AddToCartUseCase(this._repository);
  final CartRepository _repository;

  @override
  Future<Either<Failure, void>> call(AddToCartParams p) =>
      _repository.addItem(p.product, p.quantity);
}

class RemoveFromCartUseCase implements UseCase<void, String> {
  RemoveFromCartUseCase(this._repository);
  final CartRepository _repository;

  @override
  Future<Either<Failure, void>> call(String productId) =>
      _repository.removeItem(productId);
}

class UpdateCartQuantityParams extends Equatable {
  const UpdateCartQuantityParams(this.productId, this.quantity);
  final String productId;
  final int quantity;

  @override
  List<Object> get props => [productId, quantity];
}

class UpdateCartQuantityUseCase implements UseCase<void, UpdateCartQuantityParams> {
  UpdateCartQuantityUseCase(this._repository);
  final CartRepository _repository;

  @override
  Future<Either<Failure, void>> call(UpdateCartQuantityParams p) =>
      _repository.updateQuantity(p.productId, p.quantity);
}

class ClearCartUseCase implements UseCase<void, NoParams> {
  ClearCartUseCase(this._repository);
  final CartRepository _repository;

  @override
  Future<Either<Failure, void>> call(NoParams _) => _repository.clearCart();
}
