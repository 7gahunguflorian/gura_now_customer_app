import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/payment_proof.dart';
import '../repositories/payment_repository.dart';

class ValidatePaymentProofParams extends Equatable {
  const ValidatePaymentProofParams({
    required this.proofId,
    required this.status,
    this.rejectionReason,
  });
  final String proofId;
  final String status;
  final String? rejectionReason;

  @override
  List<Object?> get props => [proofId, status, rejectionReason];
}

class ValidatePaymentProofUseCase
    implements UseCase<PaymentProof, ValidatePaymentProofParams> {
  ValidatePaymentProofUseCase(this._repository);
  final PaymentRepository _repository;

  @override
  Future<Either<Failure, PaymentProof>> call(ValidatePaymentProofParams p) =>
      _repository.validatePaymentProof(
          p.proofId, p.status, p.rejectionReason);
}
