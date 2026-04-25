import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/notification.dart';
import '../../domain/usecases/delete_notification_usecase.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/get_unread_count_usecase.dart';
import '../../domain/usecases/mark_all_read_usecase.dart';
import '../../domain/usecases/mark_as_read_usecase.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc({
    required GetNotificationsUseCase getNotificationsUseCase,
    required GetUnreadCountUseCase getUnreadCountUseCase,
    required MarkAsReadUseCase markAsReadUseCase,
    required MarkAllNotificationsReadUseCase markAllReadUseCase,
    required DeleteNotificationUseCase deleteNotificationUseCase,
  })  : _getNotifications = getNotificationsUseCase,
        _getUnreadCount = getUnreadCountUseCase,
        _markAsRead = markAsReadUseCase,
        _markAllRead = markAllReadUseCase,
        _deleteNotification = deleteNotificationUseCase,
        super(const NotificationState()) {
    on<NotificationsLoadRequested>(_onLoadRequested);
    on<UnreadCountRequested>(_onUnreadCountRequested);
    on<NotificationMarkReadRequested>(_onMarkReadRequested);
    on<NotificationsMarkAllReadRequested>(_onMarkAllReadRequested);
    on<NotificationDeletedRequested>(_onDeletedRequested);
  }

  final GetNotificationsUseCase _getNotifications;
  final GetUnreadCountUseCase _getUnreadCount;
  final MarkAsReadUseCase _markAsRead;
  final MarkAllNotificationsReadUseCase _markAllRead;
  final DeleteNotificationUseCase _deleteNotification;

  Future<void> _onLoadRequested(
    NotificationsLoadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(listStatus: NotificationListStatus.loading, listError: null));
    final result = await _getNotifications(GetNotificationsParams(
      unreadOnly: event.unreadOnly,
      skip: event.skip,
      limit: event.limit,
    ));
    result.fold(
      (f) => emit(state.copyWith(listStatus: NotificationListStatus.failure, listError: f.message)),
      (list) => emit(state.copyWith(listStatus: NotificationListStatus.success, notifications: list)),
    );
  }

  Future<void> _onUnreadCountRequested(
    UnreadCountRequested event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(unreadCountStatus: NotificationListStatus.loading, unreadCountError: null));
    final result = await _getUnreadCount(NoParams());
    result.fold(
      (f) => emit(state.copyWith(unreadCountStatus: NotificationListStatus.failure, unreadCountError: f.message)),
      (count) => emit(state.copyWith(unreadCountStatus: NotificationListStatus.success, unreadCount: count)),
    );
  }

  Future<void> _onMarkReadRequested(
    NotificationMarkReadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(actionStatus: NotificationActionStatus.loading, actionError: null));
    final result =
        await _markAsRead(MarkAsReadParams(notificationId: event.notificationId));
    result.fold(
      (f) => emit(state.copyWith(actionStatus: NotificationActionStatus.failure, actionError: f.message)),
      (_) {
        emit(state.copyWith(actionStatus: NotificationActionStatus.success));
        add(const UnreadCountRequested());
        add(const NotificationsLoadRequested());
      },
    );
  }

  Future<void> _onMarkAllReadRequested(
    NotificationsMarkAllReadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(actionStatus: NotificationActionStatus.loading, actionError: null));
    final result = await _markAllRead(NoParams());
    result.fold(
      (f) => emit(state.copyWith(actionStatus: NotificationActionStatus.failure, actionError: f.message)),
      (_) {
        emit(state.copyWith(actionStatus: NotificationActionStatus.success));
        add(const UnreadCountRequested());
        add(const NotificationsLoadRequested());
      },
    );
  }

  Future<void> _onDeletedRequested(
    NotificationDeletedRequested event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(actionStatus: NotificationActionStatus.loading, actionError: null));
    final result = await _deleteNotification(event.notificationId);
    result.fold(
      (f) => emit(state.copyWith(actionStatus: NotificationActionStatus.failure, actionError: f.message)),
      (_) {
        emit(state.copyWith(actionStatus: NotificationActionStatus.success));
        add(const UnreadCountRequested());
        add(const NotificationsLoadRequested());
      },
    );
  }
}
