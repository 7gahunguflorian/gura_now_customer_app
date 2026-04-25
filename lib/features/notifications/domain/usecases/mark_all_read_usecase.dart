import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/notification_repository.dart';

class MarkAllNotificationsReadUseCase implements UseCase<int, NoParams> {
  MarkAllNotificationsReadUseCase(this._repository);
  final NotificationRepository _repository;

  @override
  Future<Either<Failure, int>> call(NoParams _) =>
      _repository.markAllAsRead();
}
