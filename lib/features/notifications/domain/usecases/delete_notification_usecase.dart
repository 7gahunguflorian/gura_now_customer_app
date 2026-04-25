import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/notification_repository.dart';

class DeleteNotificationUseCase implements UseCase<void, String> {
  DeleteNotificationUseCase(this._repository);
  final NotificationRepository _repository;

  @override
  Future<Either<Failure, void>> call(String notificationId) =>
      _repository.deleteNotification(notificationId);
}
