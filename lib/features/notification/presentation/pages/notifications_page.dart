import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/features/notification/presentation/state/notification_state.dart';
import 'package:sewa_hub/features/notification/presentation/view_model/notification_view_model.dart';
import 'package:sewa_hub/features/notification/presentation/widgets/notification_tile.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationViewModelProvider.notifier).fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationViewModelProvider);
    final vm    = ref.read(notificationViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation:       0,
        centerTitle:     false,
        iconTheme:       const IconThemeData(color: Colors.black87),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          // Mark all read
          if (state.unreadCount > 0)
            TextButton(
              onPressed: vm.markAllRead,
              child: const Text(
                'Mark all read',
                style: TextStyle(
                  color: Color(0xFFEE7A40),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          // Delete all
          if (state.notifications.isNotEmpty)
            IconButton(
              onPressed: () => _confirmDeleteAll(context, vm.deleteAll),
              icon: const Icon(Icons.delete_outline, color: Colors.black54),
            ),
        ],
      ),
      body: Builder(builder: (_) {
        // Loading
        if (state.status == NotificationStatus.loading) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFFEE7A40)));
        }

        // Error
        if (state.status == NotificationStatus.error) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wifi_off_outlined,
                    size: 48, color: Colors.grey),
                const SizedBox(height: 12),
                Text(state.errorMessage ?? 'Something went wrong',
                    style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: vm.fetchNotifications,
                  child: const Text('Retry',
                      style: TextStyle(color: Color(0xFFEE7A40))),
                ),
              ],
            ),
          );
        }

        // Empty
        if (state.notifications.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.notifications_off_outlined,
                    size: 56, color: Colors.grey),
                SizedBox(height: 12),
                Text('No notifications yet',
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          );
        }

        // List
        return RefreshIndicator(
          color: const Color(0xFFEE7A40),
          onRefresh: vm.fetchNotifications,
          child: ListView.separated(
            itemCount: state.notifications.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: Color(0xFFF0F0F0)),
            itemBuilder: (context, index) {
              final notif = state.notifications[index];
              return NotificationTile(
                notification: notif,
                onTap: () {
                  if (!notif.isRead) vm.markOneRead(notif.id);
                },
              );
            },
          ),
        );
      }),
    );
  }

  void _confirmDeleteAll(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear all notifications?'),
        content: const Text('This will permanently delete all notifications.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('Delete',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}