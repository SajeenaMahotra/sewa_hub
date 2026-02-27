import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/features/notification/presentation/pages/notifications_page.dart';
import 'package:sewa_hub/features/notification/presentation/view_model/notification_view_model.dart';

/// Drop-in bell button with an unread badge.
/// Used in HomeScreen top bar and any other header.
class NotificationBell extends ConsumerWidget {
  final double sf;
  final Color iconColor;
  final Color badgeColor;

  const NotificationBell({
    super.key,
    this.sf         = 1.0,
    this.iconColor  = Colors.black87,
    this.badgeColor = Colors.red,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(
      notificationViewModelProvider.select((s) => s.unreadCount),
    );

    return Material(
      color: Colors.grey.shade100,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NotificationsPage()),
        ),
        child: Padding(
          padding: EdgeInsets.all(9 * sf),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                Icons.notifications_outlined,
                color: iconColor,
                size: 20 * sf,
              ),
              if (unread > 0)
                Positioned(
                  top:   -4 * sf,
                  right: -4 * sf,
                  child: Container(
                    width:  16 * sf,
                    height: 16 * sf,
                    decoration: BoxDecoration(
                      color:  badgeColor,
                      shape:  BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        unread > 9 ? '9+' : '$unread',
                        style: TextStyle(
                          color:      Colors.white,
                          fontSize:   7 * sf,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}