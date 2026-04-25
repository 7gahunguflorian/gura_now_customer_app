import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../shop/domain/entities/product.dart';

abstract class ProductRepository {
  Future<Either<Failure, Product>> getProductById(String id);
}
