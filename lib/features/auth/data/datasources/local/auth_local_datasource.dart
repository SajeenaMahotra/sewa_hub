import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/core/services/hive/hive_service.dart';
import 'package:sewa_hub/core/services/storage/user_session_service.dart';
import 'package:sewa_hub/features/auth/data/datasources/auth_datasource.dart';
import 'package:sewa_hub/features/auth/data/models/auth_hive_model.dart';

//Provider
final authLocalDatasourceProvider = Provider<AuthLocalDatasource>((ref) {
  final hiveService = ref.read(hiveServiceProvider);
  final userSessionService = ref.read(userSessionServiceProvider);
  return AuthLocalDatasource(
    hiveService: hiveService,
    userSessionService: userSessionService,
  );
});

class AuthLocalDatasource implements IAuthLocalDatasource {
  final HiveService _hiveService;
  final UserSessionService _userSessionService;

  AuthLocalDatasource({
    required HiveService hiveService,
    required UserSessionService userSessionService,
  }) : _hiveService = hiveService,
       _userSessionService = userSessionService;

  @override
  Future<AuthHiveModel> getCurrentUser() {
    // TODO: implement getCurrentUser
    throw UnimplementedError();
  }

  @override
  Future<bool> isEmailExists(String email) {
    try {
      final exists = _hiveService.isEmailExists(email);
      return Future.value(exists);
    } catch (e) {
      return Future.value(false);
    }
  }

  @override
  Future<bool> logOut() async {
    try {
      await _hiveService.logOut();
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  }

  @override
  Future<AuthHiveModel?> login(String email, String password) async {
    try {
      //to save user's details in shared prefs
      final user = await _hiveService.login(email, password);
      if (user != null) {
        await _userSessionService.saveUserSession(
          userId: user.authId!,
          email: user.email,
          fullName: user.fullName,
          pofilePicture: user.profilePicture ?? '',
        );
      }
      return user;
    } catch (e) {
      return Future.value(null);
    }
  }

  @override
  Future<bool> register(AuthHiveModel authModel) async {
    try {
      await _hiveService.registerUser(authModel);
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  }
  
  @override
  Future<AuthHiveModel?> getUserById(String authId) {
    // TODO: implement getUserById
    throw UnimplementedError();
  }
}
