import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/core/services/hive/hive_service.dart';
import 'package:sewa_hub/core/services/storage/user_session_service.dart';
import 'package:sewa_hub/features/profile/data/models/profile_hive_model.dart';
import 'package:sewa_hub/features/profile/domain/entities/profile_entity.dart';

// ── Interface ──────────────────────────────────────────────────────────────

abstract interface class IProfileLocalDatasource {
  /// Get cached profile for the given email
  Future<ProfileHiveModel?> getProfile(String email);

  /// Save or update cached profile
  Future<void> saveProfile(ProfileHiveModel profile);

  /// Clear cached profile on logout
  Future<void> clearProfile(String email);
}

// ── Provider ───────────────────────────────────────────────────────────────

final profileLocalDatasourceProvider = Provider<ProfileLocalDatasource>((ref) {
  return ProfileLocalDatasource(
    hiveService: ref.read(hiveServiceProvider),
    userSessionService: ref.read(userSessionServiceProvider),
  );
});

// ── Implementation ─────────────────────────────────────────────────────────

class ProfileLocalDatasource implements IProfileLocalDatasource {
  final HiveService _hiveService;
  final UserSessionService _userSessionService;

  ProfileLocalDatasource({
    required HiveService hiveService,
    required UserSessionService userSessionService,
  })  : _hiveService = hiveService,
        _userSessionService = userSessionService;

  @override
  Future<ProfileHiveModel?> getProfile(String email) async {
    try {
      return _hiveService.getProfile(email);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveProfile(ProfileHiveModel profile) async {
    try {
      await _hiveService.saveProfile(profile);
    } catch (e) {
      // fail silently — cache is best-effort
    }
  }

  @override
  Future<void> clearProfile(String email) async {
    try {
      await _hiveService.clearProfile(email);
    } catch (e) {
      // fail silently
    }
  }
}