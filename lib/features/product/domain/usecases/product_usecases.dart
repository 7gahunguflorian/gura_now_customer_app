import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../shop/domain/entities/product.dart';
import '../repositories/product_repository.dart';

class GetProductByIdUseCase implements UseCase<Product, ProductIdParam> {
  GetProductByIdUseCase(this._repository);
  final ProductRepository _repository;

  @override
  Future<Either<Failure, Product>> call(ProductIdParam params) =>
      _repository.getProductById(params.id);
}

class ProductIdParam extends Equatable {
  const ProductIdParam(this.id);
  final String id;

  @override
  List<Object> get props => [id];
}
