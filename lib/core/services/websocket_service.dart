import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../constants/app_config.dart';

/// WebSocket connection status.
enum WebSocketStatus {
  disconnected,
  connecting,
  connected,
  error,
}

/// WebSocket message types.
class WSMessageType {
  static const String connected = 'connected';
  static const String error = 'error';

  // Delivery tracking
  static const String deliveryLocationUpdate = 'delivery:location_update';
  static const String deliveryStatusChange = 'delivery:status_change';
  static const String deliveryEtaUpdate = 'delivery:eta_update';

  // Order updates
  static const String orderStatusChange = 'order:status_change';
  static const String orderPaymentUpdate = 'order:payment_update';
  static const String orderDriverAssigned = 'order:driver_assigned';

  // Notifications
  static const String notificationNew = 'notification:new';
  static const String notificationCount = 'notification:count';

  // Admin
  static const String adminAlert = 'admin:alert';
  static const String adminStatsUpdate = 'admin:stats_update';
}

/// WebSocket message.
class WSMessage {
  const WSMessage({
    required this.type,
    required this.data,
  });

  factory WSMessage.fromJson(Map<String, dynamic> json) {
    return WSMessage(
      type: json['type'] as String,
      data: json['data'] as Map<String, dynamic>? ?? {},
    );
  }
  final String type;
  final Map<String, dynamic> data;

  Map<String, dynamic> toJson() => {
        'type': type,
        'data': data,
      };
}

/// WebSocket service for real-time communication.
class WebSocketService {
  WebSocketChannel? _channel;
  final _statusController = StreamController<WebSocketStatus>.broadcast();
  final _messageController = StreamController<WSMessage>.broadcast();
  final Set<String> _subscribedChannels = {};
  Timer? _reconnectTimer;
  String? _authToken;
  bool _shouldReconnect = true;

  /// Stream of connection status updates.
  Stream<WebSocketStatus> get statusStream => _statusController.stream;

  /// Stream of incoming messages.
  Stream<WSMessage> get messageStream => _messageController.stream;

  /// Current connection status.
  WebSocketStatus _status = WebSocketStatus.disconnected;
  WebSocketStatus get status => _status;

  /// Connect to WebSocket server.
  Future<void> connect(String authToken) async {
    if (_status == WebSocketStatus.connected ||
        _status == WebSocketStatus.connecting) {
      return;
    }

    _authToken = authToken;
    _shouldReconnect = true;
    await _connect();
  }

  Future<void> _connect() async {
    _updateStatus(WebSocketStatus.connecting);

    try {
      final wsUrl = Uri.parse('${AppConfig.wsBaseUrl}?token=$_authToken');
      _channel = WebSocketChannel.connect(wsUrl);

      await _channel!.ready;
      _updateStatus(WebSocketStatus.connected);

      // Listen to messages
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnect,
        cancelOnError: false,
      );

      // Re-subscribe to channels
      for (final channel in _subscribedChannels) {
        _sendJoinChannel(channel);
      }
    } catch (e) {
      _updateStatus(WebSocketStatus.error);
      _scheduleReconnect();
    }
  }

  void _handleMessage(dynamic message) {
    try {
      final json = jsonDecode(message as String) as Map<String, dynamic>;
      final wsMessage = WSMessage.fromJson(json);
      _messageController.add(wsMessage);
    } catch (e) {
      // Ignore malformed messages
    }
  }

  void _handleError(dynamic error) {
    _updateStatus(WebSocketStatus.error);
    _scheduleReconnect();
  }

  void _handleDisconnect() {
    _updateStatus(WebSocketStatus.disconnected);
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (!_shouldReconnect) return;

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (_shouldReconnect && _authToken != null) {
        _connect();
      }
    });
  }

  void _updateStatus(WebSocketStatus newStatus) {
    _status = newStatus;
    _statusController.add(newStatus);
  }

  /// Subscribe to a channel.
  void subscribeToChannel(String channel) {
    _subscribedChannels.add(channel);
    if (_status == WebSocketStatus.connected) {
      _sendJoinChannel(channel);
    }
  }

  /// Unsubscribe from a channel.
  void unsubscribeFromChannel(String channel) {
    _subscribedChannels.remove(channel);
    if (_status == WebSocketStatus.connected) {
      _sendLeaveChannel(channel);
    }
  }

  void _sendJoinChannel(String channel) {
    _send({
      'action': 'join',
      'channel': channel,
    });
  }

  void _sendLeaveChannel(String channel) {
    _send({
      'action': 'leave',
      'channel': channel,
    });
  }

  /// Send a message.
  void _send(Map<String, dynamic> message) {
    if (_status == WebSocketStatus.connected) {
      _channel?.sink.add(jsonEncode(message));
    }
  }

  /// Disconnect from WebSocket server.
  void disconnect() {
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _updateStatus(WebSocketStatus.disconnected);
  }

  /// Dispose resources.
  void dispose() {
    disconnect();
    _statusController.close();
    _messageController.close();
  }

  /// Get stream for specific delivery tracking.
  Stream<WSMessage> getDeliveryUpdates(String deliveryId) {
    subscribeToChannel('delivery:$deliveryId');
    return messageStream.where((msg) =>
        msg.type == WSMessageType.deliveryLocationUpdate ||
        msg.type == WSMessageType.deliveryStatusChange ||
        msg.type == WSMessageType.deliveryEtaUpdate);
  }

  /// Get stream for specific order updates.
  Stream<WSMessage> getOrderUpdates(String orderId) {
    subscribeToChannel('order:$orderId');
    return messageStream.where((msg) =>
        msg.type == WSMessageType.orderStatusChange ||
        msg.type == WSMessageType.orderPaymentUpdate ||
        msg.type == WSMessageType.orderDriverAssigned);
  }

  /// Get stream for user notifications.
  Stream<WSMessage> getNotifications(String userId) {
    subscribeToChannel('user:$userId');
    return messageStream.where((msg) =>
        msg.type == WSMessageType.notificationNew ||
        msg.type == WSMessageType.notificationCount);
  }
}

