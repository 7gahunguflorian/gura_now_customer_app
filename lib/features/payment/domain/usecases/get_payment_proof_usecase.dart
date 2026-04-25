import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/payment_proof.dart';
import '../repositories/payment_repository.dart';

class GetPaymentProofUseCase implements UseCase<PaymentProof, String> {
  GetPaymentProofUseCase(this._repository);
  final PaymentRepository _repository;

  @override
  Future<Either<Failure, PaymentProof>> call(String proofId) =>
      _repository.getPaymentProof(proofId);
}
