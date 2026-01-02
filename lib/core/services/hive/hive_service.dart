import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sewa_hub/core/constants/hive_table_constants.dart';
import 'package:sewa_hub/features/auth/data/models/auth_hive_model.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

class HiveService {
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
  }

  Future<void> _openBoxes() async {
    await Hive.openBox<AuthHiveModel>(HiveTableConstant.authTable);
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
  Future<AuthHiveModel?> loginUser(String email, String password) async {
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
    await _authBox.clear();
  }

  // ==================== Utils ====================

  Future<void> close() async {
    await Hive.close();
  }

  //is email exists
  bool isEmailExists(String email) {
    final user = _authBox.values.where(
      (user) => user.email == email,
    );
    return user.isNotEmpty;
  }
}
