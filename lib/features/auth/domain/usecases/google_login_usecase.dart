import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/core/error/failures.dart';
import 'package:sewa_hub/core/usecases/app_usecase.dart';
import 'package:sewa_hub/features/auth/data/repositories/auth_repository.dart';
import 'package:sewa_hub/features/auth/domain/entities/auth_entity.dart';
import 'package:sewa_hub/features/auth/domain/repositories/auth_repository.dart';

class GoogleLoginParam extends Equatable {
  final String idToken;
  const GoogleLoginParam({required this.idToken});
  @override
  List<Object?> get props => [idToken];
}

final googleLoginUsecaseProvider = Provider<GoogleLoginUsecase>((ref) {
  return GoogleLoginUsecase(authRepository: ref.read(authRepositoryProvider));
});

class GoogleLoginUsecase implements UsecaseWithParams<AuthEntity, GoogleLoginParam> {
  final IAuthRepository _authRepository;
  GoogleLoginUsecase({required IAuthRepository authRepository})
      : _authRepository = authRepository;

  @override
  Future<Either<Failure, AuthEntity>> call(GoogleLoginParam params) {
    return _authRepository.loginWithGoogle(params.idToken);
  }
}