import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:sewa_hub/core/api/api_endpoints.dart';
import 'package:sewa_hub/core/services/storage/token_service.dart';

final socketServiceProvider = Provider<SocketService>((ref) {
  final token = ref.read(tokenServiceProvider).getToken() ?? '';
  return SocketService(token: token);
});

class SocketService {
  IO.Socket? _socket;
  final String _token;

  SocketService({required String token}) : _token = token;

  bool get isConnected => _socket?.connected ?? false;

  void connect() {
    if (isConnected) return;

    // Strip /api/ suffix — socket connects to root server URL
    final socketUrl = ApiEndpoints.baseUrl.replaceAll(RegExp(r'/api/?$'), '');

    _socket = IO.io(
      socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setPath('/socket.io')
          .setAuth({'token': _token})
          .disableAutoConnect()
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) => print('[Socket] ✅ Connected: ${_socket!.id}'));
    _socket!.onDisconnect((_) => print('[Socket] Disconnected'));
    _socket!.onConnectError((e) => print('[Socket] ❌ Connect error: $e'));
    _socket!.on('new_message', (d) => print('[Socket] 📩 new_message raw: $d'));
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  void joinRoom(String bookingId) =>
      _socket?.emit('join_room', {'bookingId': bookingId});

  void leaveRoom(String bookingId) =>
      _socket?.emit('leave_room', {'bookingId': bookingId});

  void sendMessage(String bookingId, String content) =>
      _socket?.emit('send_message', {'bookingId': bookingId, 'content': content});

  void markRead(String bookingId) =>
      _socket?.emit('mark_read', {'bookingId': bookingId});

  void typingStart(String bookingId) =>
      _socket?.emit('typing_start', {'bookingId': bookingId});

  void typingStop(String bookingId) =>
      _socket?.emit('typing_stop', {'bookingId': bookingId});

  // ── Listeners ─────────────────────────────────────────────────────────────

  void onNewMessage(void Function(dynamic) handler) =>
      _socket?.on('new_message', handler);

  void onRoomJoined(void Function(dynamic) handler) =>
      _socket?.on('room_joined', handler);

  void onMessagesRead(void Function(dynamic) handler) =>
      _socket?.on('messages_read', handler);

  void onUserTyping(void Function(dynamic) handler) =>
      _socket?.on('user_typing', handler);

  void onUserStoppedTyping(void Function(dynamic) handler) =>
      _socket?.on('user_stopped_typing', handler);

  void onError(void Function(dynamic) handler) =>
      _socket?.on('error', handler);

  void off(String event) => _socket?.off(event);
}