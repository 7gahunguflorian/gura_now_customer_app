/// Notification remote data source for Gura Now application.
library;


import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/notification_model.dart';

/// Abstract interface for notification remote operations.
abstract class NotificationRemoteDataSource {
  /// Get user notifications.
  Future<List<NotificationModel>> getNotifications({
    bool unreadOnly = false,
    int skip = 0,
    int limit = 50,
  });

  /// Get unread notification count.
  Future<int> getUnreadCount();

  /// Mark a notification as read.
  Future<NotificationModel> markAsRead(String notificationId);

  /// Mark all notifications as read.
  Future<int> markAllAsRead();

  /// Delete a notification.
  Future<void> deleteNotification(String notificationId);

  /// Register FCM token.
  Future<FCMTokenModel> registerFcmToken(FCMTokenCreateRequest request);

  /// Get user's FCM tokens.
  Future<List<FCMTokenModel>> getFcmTokens({bool activeOnly = true});

  /// Deactivate an FCM token.
  Future<void> deactivateFcmToken(String tokenId);
}

/// Implementation of notification remote data source.
class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  NotificationRemoteDataSourceImpl(this._apiClient);
  final ApiClient _apiClient;

  @override
  Future<List<NotificationModel>> getNotifications({
    bool unreadOnly = false,
    int skip = 0,
    int limit = 50,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.notificationsList,
      queryParams: {
        'unread_only': unreadOnly,
        'skip': skip,
        'limit': limit,
      },
    );
    final data = response['data'] as List<dynamic>? ??
        response['items'] as List<dynamic>? ??
        [];
    return data
        .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<int> getUnreadCount() async {
    final response = await _apiClient.get('/notifications/unread-count');
    return response['count'] as int? ?? 0;
  }

  @override
  Future<NotificationModel> markAsRead(String notificationId) async {
    final endpoint = ApiEndpoints.replacePathParam(
      ApiEndpoints.notificationsMarkRead,
      'notification_id',
      notificationId,
    );
    final response = await _apiClient.patch(endpoint);
    return NotificationModel.fromJson(response);
  }

  @override
  Future<int> markAllAsRead() async {
    final response = await _apiClient.post(
      ApiEndpoints.notificationsMarkAllRead,
      {},
    );
    return response['marked_read'] as int? ?? 0;
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    final endpoint = '/notifications/$notificationId';
    await _apiClient.delete(endpoint);
  }

  @override
  Future<FCMTokenModel> registerFcmToken(FCMTokenCreateRequest request) async {
    final response = await _apiClient.post(
      ApiEndpoints.notificationsFcmToken,
      request.toJson(),
    );
    return FCMTokenModel.fromJson(response);
  }

  @override
  Future<List<FCMTokenModel>> getFcmTokens({bool activeOnly = true}) async {
    final response = await _apiClient.get(
      '/notifications/fcm-tokens',
      queryParams: {'active_only': activeOnly},
    );
    final data = response['data'] as List<dynamic>? ??
        response['items'] as List<dynamic>? ??
        [];
    return data
        .map((json) => FCMTokenModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> deactivateFcmToken(String tokenId) async {
    await _apiClient.delete('/notifications/fcm-token/$tokenId');
  }
}
