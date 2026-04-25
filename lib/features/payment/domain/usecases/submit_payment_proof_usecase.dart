import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/payment_proof.dart';
import '../repositories/payment_repository.dart';

class SubmitPaymentProofParams extends Equatable {
  const SubmitPaymentProofParams({
    required this.orderId,
    required this.paymentMethod,
    required this.imageUrls,
    this.referenceNumber,
    this.notes,
  });
  final String orderId;
  final String paymentMethod;
  final List<String> imageUrls;
  final String? referenceNumber;
  final String? notes;

  @override
  List<Object?> get props =>
      [orderId, paymentMethod, imageUrls, referenceNumber, notes];
}

class SubmitPaymentProofUseCase
    implements UseCase<PaymentProof, SubmitPaymentProofParams> {
  SubmitPaymentProofUseCase(this._repository);
  final PaymentRepository _repository;

  @override
  Future<Either<Failure, PaymentProof>> call(SubmitPaymentProofParams p) =>
      _repository.submitPaymentProof(
        orderId: p.orderId,
        paymentMethod: p.paymentMethod,
        imageUrls: p.imageUrls,
        referenceNumber: p.referenceNumber,
        notes: p.notes,
      );
}
