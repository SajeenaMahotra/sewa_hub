import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/core/services/hive/hive_service.dart';
import 'package:sewa_hub/features/auth/data/datasources/auth_datasource.dart';
import 'package:sewa_hub/features/auth/data/models/auth_hive_model.dart';

//Provider
final authLocalDatasourceProvider = Provider<AuthLocalDatasource>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return AuthLocalDatasource(hiveService: hiveService);
});

class AuthLocalDatasource implements IAuthDatasource {
  final HiveService _hiveService;

  AuthLocalDatasource({required HiveService hiveService})
    : _hiveService = hiveService;

  @override
  Future<AuthHiveModel> getCurrentUser() {
    // TODO: implement getCurrentUser
    throw UnimplementedError();
  }

  @override
  Future<bool> isEmailExists(String email) {
    try{
      final exists = _hiveService.isEmailExists(email);
      return Future.value(exists);
    } catch (e) {
      return Future.value(false);
    }
  }

  @override
  Future<bool> logOut() async{
    try{
      await _hiveService.logOut();
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  }

  @override
  Future<AuthHiveModel?> login(String email, String password)async {
    try{
      final user = await _hiveService.loginUser(email, password);
      return Future.value(user);
    }catch(e){
      return Future.value(null);
    }
  }

  @override
  Future<bool> register(AuthHiveModel authModel) async{
    try{
      await _hiveService.registerUser(authModel);
      return Future.value(true);
    }catch(e){
      return Future.value(false);
    }
  }
}
