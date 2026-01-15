import 'package:sewa_hub/features/auth/data/models/auth_hive_model.dart';

abstract interface class IAuthLocalDatasource{
  Future<bool> register(AuthHiveModel authModel);
  Future<AuthHiveModel?> login(String email, String password);
  Future<AuthHiveModel> getCurrentUser();
  Future<bool> logOut();
  Future<AuthHiveModel?> getUserById(String authId);
  //get email exists
  Future<bool> isEmailExists(String email);
}

abstract interface class IAuthRemoteDataScource{
  Future<AuthHiveModel> register(AuthHiveModel user);
  Future<AuthHiveModel?> login(String email, String password);
  Future<AuthHiveModel?> getUserById(String authId);
}