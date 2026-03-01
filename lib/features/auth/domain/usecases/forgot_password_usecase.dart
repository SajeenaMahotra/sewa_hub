import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/core/error/failures.dart';
import 'package:sewa_hub/core/usecases/app_usecase.dart';
import 'package:sewa_hub/features/auth/data/repositories/auth_repository.dart';
import 'package:sewa_hub/features/auth/domain/repositories/auth_repository.dart';

class ForgotPasswordParam extends Equatable {
  final String email;
  const ForgotPasswordParam({required this.email});
  @override
  List<Object?> get props => [email];
}

final forgotPasswordUsecaseProvider = Provider<ForgotPasswordUsecase>((ref) {
  return ForgotPasswordUsecase(authRepository: ref.read(authRepositoryProvider));
});

class ForgotPasswordUsecase implements UsecaseWithParams<bool, ForgotPasswordParam> {
  final IAuthRepository _authRepository;
  ForgotPasswordUsecase({required IAuthRepository authRepository})
      : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(ForgotPasswordParam params) {
    return _authRepository.forgotPassword(params.email);
  }
}