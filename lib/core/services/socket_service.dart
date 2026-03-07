import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:sewa_hub/core/api/api_endpoints.dart';
import 'package:sewa_hub/core/services/storage/token_service.dart';

final socketServiceProvider = Provider<SocketService>((ref) {
  final token = ref.read(tokenServiceProvider).getToken() ?? '';
  print('[Socket] token: ${token.isEmpty ? "EMPTY!" : "${token.substring(0, 20)}..."}');
  return SocketService(token: token);
});

class SocketService {
  IO.Socket? _socket;
  final String _token;

  String? _pendingRoom;
  final Map<String, List<void Function(dynamic)>> _handlers = {};

  SocketService({required String token}) : _token = token;

  bool get isConnected => _socket?.connected ?? false;

  void connect() {
    if (_socket != null) {
      if (!isConnected) _socket!.connect();
      return;
    }

    // Strip /api suffix and append /chat namespace
    final base = ApiEndpoints.baseUrl.replaceAll(RegExp(r'/api/?$'), '');
    final socketUrl = '$base/chat'; // ← /chat namespace
    print('[Socket] Connecting to: $socketUrl');

    _socket = IO.io(
      socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setPath('/socket.io')
          .setAuth({'token': _token})
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(5)
          .build(),
    );

    _socket!.onConnect((_) {
      print('[Socket] ✅ Connected: ${_socket!.id}');
      // Re-attach all handlers after reconnect
      _handlers.forEach((event, handlers) {
        for (final h in handlers) {
          _socket!.on(event, h);
        }
      });
      // Join queued room
      if (_pendingRoom != null) {
        print('[Socket] Joining pending room: $_pendingRoom');
        _socket!.emit('join_room', {'bookingId': _pendingRoom});
        _pendingRoom = null;
      }
    });

    _socket!.onDisconnect((r) => print('[Socket] ❌ Disconnected: $r'));
    _socket!.onConnectError((e) => print('[Socket] ❌ Connect error: $e'));
    _socket!.onError((e) => print('[Socket] ❌ Error: $e'));

    // Debug: log ALL incoming events
    _socket!.onAny((event, data) =>
        print('[Socket] 📨 EVENT: $event | DATA: $data'));

    _socket!.connect();
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _handlers.clear();
    _pendingRoom = null;
  }

  void joinRoom(String bookingId) {
    if (isConnected) {
      print('[Socket] Joining room: $bookingId');
      _socket!.emit('join_room', {'bookingId': bookingId});
    } else {
      print('[Socket] Queuing room: $bookingId');
      _pendingRoom = bookingId;
    }
  }

  void leaveRoom(String bookingId) =>
      _socket?.emit('leave_room', {'bookingId': bookingId});

  void sendMessage(String bookingId, String content) {
    print('[Socket] send_message → bookingId=$bookingId content=$content connected=$isConnected');
    _socket?.emit('send_message', {'bookingId': bookingId, 'content': content});
  }

  void markRead(String bookingId) =>
      _socket?.emit('mark_read', {'bookingId': bookingId});

  void typingStart(String bookingId) =>
      _socket?.emit('typing_start', {'bookingId': bookingId});

  void typingStop(String bookingId) =>
      _socket?.emit('typing_stop', {'bookingId': bookingId});

  void _addHandler(String event, void Function(dynamic) handler) {
    _handlers.putIfAbsent(event, () => []).add(handler);
    if (isConnected) _socket?.on(event, handler);
  }

  void onNewMessage(void Function(dynamic) h) => _addHandler('new_message', h);
  void onRoomJoined(void Function(dynamic) h) => _addHandler('room_joined', h);
  void onMessagesRead(void Function(dynamic) h) => _addHandler('messages_read', h);
  void onUserTyping(void Function(dynamic) h) => _addHandler('user_typing', h);
  void onUserStoppedTyping(void Function(dynamic) h) => _addHandler('user_stopped_typing', h);
  void onError(void Function(dynamic) h) => _addHandler('error', h);

  void off(String event) {
    _handlers.remove(event);
    _socket?.off(event);
  }
}