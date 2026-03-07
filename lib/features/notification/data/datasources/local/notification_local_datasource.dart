import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/core/services/hive/hive_service.dart';
import 'package:sewa_hub/features/notification/data/models/notification_hive_model.dart';

abstract interface class INotificationLocalDatasource {
  Future<List<NotificationHiveModel>> getNotifications(String recipientId);
  Future<void> saveNotifications(List<NotificationHiveModel> notifications);
  Future<void> markAllRead(String recipientId);
  Future<void> markOneRead(String id);
  Future<void> deleteAll(String recipientId);
}

final notificationLocalDatasourceProvider =
    Provider<NotificationLocalDatasource>((ref) {
  return NotificationLocalDatasource(
    hiveService: ref.read(hiveServiceProvider),
  );
});

class NotificationLocalDatasource implements INotificationLocalDatasource {
  final HiveService _hiveService;

  NotificationLocalDatasource({required HiveService hiveService})
      : _hiveService = hiveService;

  @override
  Future<List<NotificationHiveModel>> getNotifications(
      String recipientId) async {
    try {
      return _hiveService.getNotifications(recipientId);
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> saveNotifications(
      List<NotificationHiveModel> notifications) async {
    try {
      await _hiveService.saveNotifications(notifications);
    } catch (_) {}
  }

  @override
  Future<void> markAllRead(String recipientId) async {
    try {
      await _hiveService.markAllNotificationsRead(recipientId);
    } catch (_) {}
  }

  @override
  Future<void> markOneRead(String id) async {
    try {
      await _hiveService.markOneNotificationRead(id);
    } catch (_) {}
  }

  @override
  Future<void> deleteAll(String recipientId) async {
    try {
      await _hiveService.deleteAllNotifications(recipientId);
    } catch (_) {}
  }
}