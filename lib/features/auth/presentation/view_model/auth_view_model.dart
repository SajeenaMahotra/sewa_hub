import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/features/auth/domain/usecases/login_usecase.dart';
import 'package:sewa_hub/features/auth/domain/usecases/register_usecase.dart';
import 'package:sewa_hub/features/auth/domain/usecases/google_login_usecase.dart';
import 'package:sewa_hub/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:sewa_hub/features/profile/domain/usecases/change_password_usecase.dart';
import 'package:sewa_hub/features/auth/presentation/state/auth_state.dart';

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(() {
  return AuthViewModel();
});

class AuthViewModel extends Notifier<AuthState> {
  late final RegisterUsecase _registerUsecase;
  late final LoginUsecase _loginUsecase;
  late final GoogleLoginUsecase _googleLoginUsecase;
  late final ForgotPasswordUsecase _forgotPasswordUsecase;
  late final ChangePasswordUsecase _changePasswordUsecase;

  @override
  AuthState build() {
    _registerUsecase = ref.read(registerUsecaseProvider);
    _loginUsecase = ref.read(loginUsecaseProvider);
    _googleLoginUsecase = ref.read(googleLoginUsecaseProvider);
    _forgotPasswordUsecase = ref.read(forgotPasswordUsecaseProvider);
    _changePasswordUsecase = ref.read(changePasswordUsecaseProvider);
    return const AuthState();
  }

  Future<void> register({required String fullName, required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading);
    final result = await _registerUsecase.call(
      RegisterUsecaseParam(fullName: fullName, email: email, password: password),
    );
    result.fold(
      (failure) => state = state.copyWith(status: AuthStatus.error, errorMessage: failure.toString()),
      (isRegistered) => state = state.copyWith(
        status: isRegistered ? AuthStatus.registered : AuthStatus.error,
        errorMessage: isRegistered ? null : 'Registration failed',
      ),
    );
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading);
    final result = await _loginUsecase.call(LoginUsecaseParam(email: email, password: password));
    result.fold(
      (failure) => state = state.copyWith(status: AuthStatus.error, errorMessage: failure.toString()),
      (authEntity) => state = state.copyWith(status: AuthStatus.authenticated, authEntity: authEntity),
    );
  }


  Future<void> loginWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading);
    final result = await _googleLoginUsecase.call();
    result.fold(
      (failure) => state = state.copyWith(status: AuthStatus.error, errorMessage: failure.toString()),
      (authEntity) => state = state.copyWith(status: AuthStatus.authenticated, authEntity: authEntity),
    );
  }


  Future<void> forgotPassword({required String email}) async {
    state = state.copyWith(status: AuthStatus.loading);
    final result = await _forgotPasswordUsecase.call(ForgotPasswordParam(email: email));
    result.fold(
      (failure) => state = state.copyWith(status: AuthStatus.error, errorMessage: failure.toString()),
      (_) => state = state.copyWith(status: AuthStatus.forgotPasswordSent),
    );
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    final result = await _changePasswordUsecase.call(ChangePasswordParam(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmNewPassword: confirmNewPassword,
    ));
    result.fold(
      (failure) => state = state.copyWith(status: AuthStatus.error, errorMessage: failure.toString()),
      (_) => state = state.copyWith(status: AuthStatus.passwordChanged),
    );
  }
}