import 'package:dartz/dartz.dart' hide Order;

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_datasource.dart';

class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl(this._remoteDataSource);
  final OrderRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, Order>> createOrder(Map<String, dynamic> orderData) async {
    try {
      final model = await _remoteDataSource.createOrder(orderData);
      return Right(model); // OrderModel extends Order
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Order>>> getOrders() async {
    try {
      final models = await _remoteDataSource.getOrders();
      return Right(List<Order>.from(models));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Order>> getOrderDetail(String id) async {
    try {
      final model = await _remoteDataSource.getOrderDetail(id);
      return Right(model); // OrderModel extends Order
    } on NotFoundException catch (e) {
      return Left(ServerFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> confirmOrder(String orderId) async {
    try {
      await _remoteDataSource.confirmOrder(orderId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> confirmCustomer(String orderId) async {
    try {
      await _remoteDataSource.confirmCustomer(orderId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
