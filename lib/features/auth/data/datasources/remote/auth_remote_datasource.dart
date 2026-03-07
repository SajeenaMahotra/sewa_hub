import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:sewa_hub/core/api/api_client.dart';
import 'package:sewa_hub/core/api/api_endpoints.dart';
import 'package:sewa_hub/core/services/storage/token_service.dart';
import 'package:sewa_hub/core/services/storage/user_session_service.dart';
import 'package:sewa_hub/features/auth/data/datasources/auth_datasource.dart';
import 'package:sewa_hub/features/auth/data/models/auth_api_model.dart';
import 'package:sewa_hub/features/auth/data/models/auth_hive_model.dart';

//Create provider
final authRemoteDatasourceProvider = Provider<IAuthRemoteDataSource>((ref) {
  return AuthRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    userSessionService: ref.read(userSessionServiceProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class AuthRemoteDatasource implements IAuthRemoteDataSource {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;
  final TokenService _tokenService;

  AuthRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _userSessionService = userSessionService,
       _tokenService = tokenService;

  @override
  Future<AuthApiModel?> getUserById(String authId) {
    // TODO: implement getUserById
    throw UnimplementedError();
  }

  @override
  Future<AuthApiModel?> login(String email, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      final user = AuthApiModel.fromJson(data);

      //Save to session
      await _userSessionService.saveUserSession(
        userId: user.authId!,
        email: user.email,
        fullName: user.fullName,
      );

      //save token
      final token = response.data['token'] as String?;
      await _tokenService.saveToken(token!);

      return user;
    }

    return null;
  }

  @override
  Future<AuthApiModel> register(AuthApiModel user) async {
    final response = await _apiClient.post(
      ApiEndpoints.register,
      data: user.toJson(),
    );
    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      final registeredUser = AuthApiModel.fromJson(data);
      return registeredUser;
    }

    return user;
  }

  @override
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.changePassword,
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'confirmNewPassword': confirmNewPassword,
      },
    );
    return response.data['success'] == true;
  }

  @override
  Future<bool> forgotPassword(String email) async {
    final response = await _apiClient.post(
      ApiEndpoints.sendResetPasswordEmail,
      data: {'email': email},
    );
    return response.data['success'] == true;
  }

  @override
Future<AuthApiModel?> loginWithGoogle(String idToken) async {
  final response = await _apiClient.post(
    ApiEndpoints.googleTokenLogin,
    data: {'idToken': idToken},
  );

  if (response.data['success'] == true) {
    final data = response.data['data'] as Map<String, dynamic>;
    final user = AuthApiModel.fromJson(data);
    final token = response.data['token'] as String;

    await _tokenService.saveToken(token);
    await _userSessionService.saveUserSession(
      userId: user.authId!,
      email: user.email,
      fullName: user.fullName,
    );
    return user;
  }
  return null;
}

  Map<String, dynamic> _decodeJwtPayload(String token) {
    final parts = token.split('.');
    if (parts.length != 3) throw Exception('Invalid JWT');
    final payload = parts[1];
    // Base64 padding fix
    final normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));
    return jsonDecode(decoded) as Map<String, dynamic>;
  }
}
