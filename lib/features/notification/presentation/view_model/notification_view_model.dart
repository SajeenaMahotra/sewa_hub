import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/features/notification/data/datasources/remote/notification_socket_service.dart';
import 'package:sewa_hub/features/notification/domain/entities/notification_entity.dart';
import 'package:sewa_hub/features/notification/domain/usecases/get_notification_usecase.dart';
import 'package:sewa_hub/features/notification/presentation/state/notification_state.dart';
import 'package:sewa_hub/features/notification/domain/usecases/notification_action_usecase.dart';

final notificationViewModelProvider =
    NotifierProvider<NotificationViewModel, NotificationState>(() {
      return NotificationViewModel();
    });

class NotificationViewModel extends Notifier<NotificationState> {
  late final GetNotificationsUsecase _getNotifications;
  late final MarkAllReadUsecase _markAllRead;
  late final MarkOneReadUsecase _markOneRead;
  late final DeleteAllNotificationsUsecase _deleteAll;
  late final NotificationSocketService _socketService;

  @override
  NotificationState build() {
    _getNotifications = ref.read(getNotificationsUsecaseProvider);
    _markAllRead = ref.read(markAllReadUsecaseProvider);
    _markOneRead = ref.read(markOneReadUsecaseProvider);
    _deleteAll = ref.read(deleteAllNotificationsUsecaseProvider);
    _socketService = ref.read(notificationSocketServiceProvider);

    // Wire real-time socket → prepend to list + bump unread count
    _socketService.onNotification = (notif) {
      state = state.copyWith(
        notifications: [notif, ...state.notifications],
        unreadCount: state.unreadCount + 1,
      );
    };

    _socketService.connect();

    // Clean up on dispose
    ref.onDispose(() => _socketService.disconnect());

    return const NotificationState();
  }

  // ── Fetch from DB ─────────────────────────────────────────────────────────
  Future<void> fetchNotifications() async {
    state = state.copyWith(status: NotificationStatus.loading);

    final result = await _getNotifications();
    result.fold(
      (failure) => state = state.copyWith(
        status: NotificationStatus.error,
        errorMessage: failure.toString(),
      ),
      (list) => state = state.copyWith(
        status: NotificationStatus.loaded,
        notifications: list,
        unreadCount: list.where((n) => !n.isRead).length,
      ),
    );
  }

  // ── Mark all read ─────────────────────────────────────────────────────────
  Future<void> markAllRead() async {
    final result = await _markAllRead();
    result.fold(
      (_) => null,
      (_) => state = state.copyWith(
        notifications: state.notifications
            .map((n) => n.copyWith(isRead: true))
            .toList(),
        unreadCount: 0,
      ),
    );
  }

  // ── Mark one read ─────────────────────────────────────────────────────────
  Future<void> markOneRead(String id) async {
    final result = await _markOneRead(id);
    result.fold((_) => null, (_) {
      final updated = state.notifications.map((n) {
        return n.id == id ? n.copyWith(isRead: true) : n;
      }).toList();
      state = state.copyWith(
        notifications: updated,
        unreadCount: updated.where((n) => !n.isRead).length,
      );
    });
  }

  // ── Delete all ────────────────────────────────────────────────────────────
  Future<void> deleteAll() async {
    final result = await _deleteAll();
    result.fold(
      (_) => null,
      (_) => state = state.copyWith(notifications: [], unreadCount: 0),
    );
  }
}
