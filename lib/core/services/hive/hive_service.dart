import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sewa_hub/core/constants/hive_table_constants.dart';
import 'package:sewa_hub/core/services/storage/user_session_service.dart';
import 'package:sewa_hub/features/auth/data/models/auth_hive_model.dart';
import 'package:sewa_hub/features/notification/data/models/notification_hive_model.dart';
import 'package:sewa_hub/features/profile/data/models/profile_hive_model.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  final userSessionService = ref.read(userSessionServiceProvider);
  return HiveService(userSessionService: userSessionService);
});

class HiveService {
  final UserSessionService _userSessionService;

  HiveService({required UserSessionService userSessionService})
    : _userSessionService = userSessionService;

  // ==================== Init ====================

  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/${HiveTableConstant.dbName}';
    Hive.init(path);
    _registerAdapters();
    await _openBoxes();
  }

  void _registerAdapters() {
    if (!Hive.isAdapterRegistered(HiveTableConstant.authTypeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }

    if (!Hive.isAdapterRegistered(HiveTableConstant.profileTypeId)) {
      Hive.registerAdapter(ProfileHiveModelAdapter());
    }
  }

  Future<void> _openBoxes() async {
    await Hive.openBox<AuthHiveModel>(HiveTableConstant.authTable);

    await Hive.openBox<ProfileHiveModel>(HiveTableConstant.profileTable);
  }

  // ==================== Auth ====================

  //boxes
  Box<AuthHiveModel> get _authBox =>
      Hive.box<AuthHiveModel>(HiveTableConstant.authTable);

  /// register user
  Future<AuthHiveModel> registerUser(AuthHiveModel user) async {
    await _authBox.put(user.authId, user);
    return user;
  }

  //login
  Future<AuthHiveModel?> login(String email, String password) async {
    final user = _authBox.values.where(
      (user) => user.email == email && user.password == password,
    );
    if (user.isNotEmpty) {
      return user.first;
    }
    return null;
  }

  /// Get current logged-in user
  AuthHiveModel? getCurrentUser(String authId) {
    return _authBox.get(authId);
  }

  /// Get user by id
  AuthHiveModel? getUserById(String authId) {
    return _authBox.get(authId);
  }

  /// Update user
  Future<void> updateUser(AuthHiveModel user) async {
    await _authBox.put(user.authId, user);
  }

  /// Sign out (clear auth data)
  Future<void> logOut() async {
    await _userSessionService.clearUserSession();
  }

  // ==================== Profile ====================

  Box<ProfileHiveModel> get _profileBox =>
      Hive.box<ProfileHiveModel>(HiveTableConstant.profileTable);

  /// Save or update cached profile (keyed by email)
  Future<void> saveProfile(ProfileHiveModel profile) async {
    await _profileBox.put(profile.email, profile);
  }

  /// Get cached profile by email
  ProfileHiveModel? getProfile(String email) {
    return _profileBox.get(email);
  }

  /// Clear cached profile (on logout)
  Future<void> clearProfile(String email) async {
    await _profileBox.delete(email);
  }

  /// Clear all cached profiles
  Future<void> clearAllProfiles() async {
    await _profileBox.clear();
  }

  // ==================== Notifications ====================

  Box<NotificationHiveModel> get _notifBox =>
      Hive.box<NotificationHiveModel>(HiveTableConstant.notificationTable);

  /// Save list — keyed by id, filtered by recipientId
  Future<void> saveNotifications(List<NotificationHiveModel> notifications) async {
    final map = {for (final n in notifications) n.id: n};
    await _notifBox.putAll(map);
  }

  /// Get all notifications for a user, sorted newest first
  List<NotificationHiveModel> getNotifications(String recipientId) {
    final list = _notifBox.values
        .where((n) => n.recipientId == recipientId)
        .toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  /// Mark all read for a user
  Future<void> markAllNotificationsRead(String recipientId) async {
    final toUpdate = _notifBox.values
        .where((n) => n.recipientId == recipientId && !n.isRead)
        .toList();
    for (final n in toUpdate) {
      await _notifBox.put(
        n.id,
        NotificationHiveModel(
          id: n.id,
          recipientId: n.recipientId,
          type: n.type,
          title: n.title,
          message: n.message,
          bookingId: n.bookingId,
          isRead: true,
          createdAt: n.createdAt,
        ),
      );
    }
  }

  /// Mark one read
  Future<void> markOneNotificationRead(String id) async {
    final n = _notifBox.get(id);
    if (n != null) {
      await _notifBox.put(
        id,
        NotificationHiveModel(
          id: n.id,
          recipientId: n.recipientId,
          type: n.type,
          title: n.title,
          message: n.message,
          bookingId: n.bookingId,
          isRead: true,
          createdAt: n.createdAt,
        ),
      );
    }
  }

  /// Delete all notifications for a user
  Future<void> deleteAllNotifications(String recipientId) async {
    final keys = _notifBox.values
        .where((n) => n.recipientId == recipientId)
        .map((n) => n.id)
        .toList();
    await _notifBox.deleteAll(keys);
  }

  // ==================== Utils ====================

  Future<void> close() async {
    await Hive.close();
  }

  //is email exists
  bool isEmailExists(String email) {
    final user = _authBox.values.where((user) => user.email == email);
    return user.isNotEmpty;
  }
}
