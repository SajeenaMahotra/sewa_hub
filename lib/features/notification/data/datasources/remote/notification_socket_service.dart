import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:sewa_hub/core/services/storage/user_session_service.dart';
import 'package:sewa_hub/features/notification/data/models/notification_api_model.dart';
import 'package:sewa_hub/features/notification/domain/entities/notification_entity.dart';

final notificationSocketServiceProvider = Provider<NotificationSocketService>((
  ref,
) {
  final session = ref.watch(userSessionServiceProvider);
  return NotificationSocketService(sessionService: session);
});

class NotificationSocketService {
  final UserSessionService _sessionService;
  IO.Socket? _socket;

  // Callback invoked when a new notification arrives in real-time
  void Function(NotificationEntity)? onNotification;

  NotificationSocketService({required UserSessionService sessionService})
    : _sessionService = sessionService;

  void connect() {
    if (_socket != null && _socket!.connected) return;

    const baseUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://10.0.2.2:5050',
    );

    _socket = IO.io(
      '$baseUrl/notifications', // ← /notifications namespace
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setPath('/socket.io')
          .disableAutoConnect()
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      final userId = _sessionService.userId;
      debugPrint('[Notif Socket] Connected. Registering userId: $userId');
      if (userId != null) {
        _socket!.emit('register', userId);
      }
    });

    _socket!.on('notification', (data) {
      debugPrint('[Notif Socket] Received: $data');
      try {
        final model = NotificationApiModel.fromJson(
          Map<String, dynamic>.from(data as Map),
        );
        onNotification?.call(model.toEntity());
      } catch (e) {
        debugPrint('[Notif Socket] Parse error: $e');
      }
    });

    _socket!.onDisconnect((_) => debugPrint('[Notif Socket] Disconnected'));

    _socket!.onError((err) => debugPrint('[Notif Socket] Error: $err'));
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  bool get isConnected => _socket?.connected ?? false;
}
