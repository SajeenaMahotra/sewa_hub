import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/features/auth/domain/usecases/login_usecase.dart';
import 'package:sewa_hub/features/auth/domain/usecases/register_usecase.dart';
import 'package:sewa_hub/features/auth/presentation/state/auth_state.dart';


//provider
final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(() {
  return AuthViewModel();
});

class AuthViewModel extends Notifier<AuthState> {

  late final RegisterUsecase _registerUsecase;
  late final LoginUsecase _loginUsecase;
  
  @override
  AuthState build() {
    _registerUsecase = ref.read(registerUsecaseProvider);
    _loginUsecase = ref.read(loginUsecaseProvider);
    return AuthState();
  }

  Future<void> register({required String fullName, required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading);
    final params= RegisterUsecaseParam(
      fullName: fullName,
      email: email,
      password: password, 
    );
    final result = await _registerUsecase.call(params);
    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.toString(),
        );
      },
      (isRegistered) {
        if (isRegistered) {
          state = state.copyWith(status: AuthStatus.registered);
        } else {
          state = state.copyWith(
            status: AuthStatus.error,
            errorMessage: "Registration failed",
          );
        }
      },
    );
  }

  //Login
  Future<void> login({
    required String email,
    required String password}) async {
    state = state.copyWith(status: AuthStatus.loading);
    final params = LoginUsecaseParam(
      email: email,
      password: password,
    );
    final result = await _loginUsecase.call(params);
    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.toString(),
        );
      },
      (authEntity) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          authEntity: authEntity,
        );
      },
    );
  }
  
}