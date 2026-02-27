import 'package:flutter/material.dart';
import 'package:sewa_hub/features/notification/domain/entities/notification_entity.dart';

class NotificationTile extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback? onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    this.onTap,
  });

  // ── Icon + colour per type ────────────────────────────────────────────────
  _TypeStyle get _style {
    switch (notification.type) {
      case NotificationType.bookingCreated:
        return _TypeStyle(Icons.calendar_today_outlined,
            Colors.blue.shade600, Colors.blue.shade50);
      case NotificationType.bookingAccepted:
        return _TypeStyle(Icons.check_circle_outline,
            Colors.green.shade600, Colors.green.shade50);
      case NotificationType.bookingRejected:
        return _TypeStyle(Icons.cancel_outlined,
            Colors.red.shade600, Colors.red.shade50);
      case NotificationType.bookingCompleted:
        return _TypeStyle(Icons.task_alt_outlined,
            Colors.orange.shade600, Colors.orange.shade50);
      case NotificationType.bookingCancelled:
        return _TypeStyle(Icons.block_outlined,
            Colors.grey.shade600, Colors.grey.shade100);
      default:
        return _TypeStyle(Icons.notifications_outlined,
            Colors.grey.shade500, Colors.grey.shade100);
    }
  }

  String _timeAgo() {
    final diff = DateTime.now().difference(notification.createdAt);
    if (diff.inMinutes < 1)  return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours   < 24) return '${diff.inHours}h ago';
    if (diff.inDays    < 7)  return '${diff.inDays}d ago';
    return '${notification.createdAt.day}/${notification.createdAt.month}/${notification.createdAt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final s = _style;
    final isUnread = !notification.isRead;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        color: isUnread ? Colors.orange.withOpacity(0.04) : Colors.white,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon badge
            Container(
              width:  40,
              height: 40,
              decoration: BoxDecoration(
                color:        s.bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(s.icon, color: s.color, size: 20),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontSize:   13.5,
                      fontWeight: isUnread
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notification.message,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.black54),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _timeAgo(),
                    style: const TextStyle(
                        fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),

            // Unread dot
            if (isUnread)
              Container(
                margin: const EdgeInsets.only(top: 4, left: 8),
                width:  8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFEE7A40),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TypeStyle {
  final IconData icon;
  final Color    color;
  final Color    bg;
  const _TypeStyle(this.icon, this.color, this.bg);
}