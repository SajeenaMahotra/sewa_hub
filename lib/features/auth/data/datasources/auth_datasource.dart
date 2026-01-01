import 'package:sewa_hub/features/auth/data/models/auth_hive_model.dart';

abstract interface class IAuthDatasource{
  Future<bool> register(AuthHiveModel authModel);
  Future<AuthHiveModel?> login(String email, String password);
  Future<AuthHiveModel> getCurrentUser();
  Future<bool> logOut();
  
  //get email exists
  Future<bool> isEmailExists(String email);
}