import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/product.dart';
import '../repositories/shop_repository.dart';

class GetShopProductsUseCase
    implements UseCase<List<Product>, GetShopProductsParams> {
  GetShopProductsUseCase(this._repository);
  final ShopRepository _repository;

  @override
  Future<Either<Failure, List<Product>>> call(
          GetShopProductsParams params) async =>
      _repository.getShopProducts(params.shopId);
}

class GetShopProductsParams extends Equatable {
  const GetShopProductsParams(this.shopId);
  final String shopId;

  @override
  List<Object> get props => [shopId];
}
