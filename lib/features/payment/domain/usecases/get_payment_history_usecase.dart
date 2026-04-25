import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/payment_repository.dart';

class GetPaymentHistoryUseCase
    implements UseCase<Map<String, dynamic>, GetPaymentHistoryParams> {
  GetPaymentHistoryUseCase(this._repository);
  final PaymentRepository _repository;

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
      GetPaymentHistoryParams params) async {
    return await _repository.getPaymentHistory(
        page: params.page, perPage: params.perPage);
  }
}

class GetPaymentHistoryParams extends Equatable {
  const GetPaymentHistoryParams({this.page = 1, this.perPage = 20});
  final int page;
  final int perPage;

  @override
  List<Object> get props => [page, perPage];
}
