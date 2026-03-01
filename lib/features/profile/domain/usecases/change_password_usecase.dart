import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/core/error/failures.dart';
import 'package:sewa_hub/core/usecases/app_usecase.dart';
import 'package:sewa_hub/features/auth/data/repositories/auth_repository.dart';
import 'package:sewa_hub/features/auth/domain/repositories/auth_repository.dart';

class ChangePasswordParam extends Equatable {
  final String currentPassword;
  final String newPassword;
  final String confirmNewPassword;

  const ChangePasswordParam({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmNewPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword, confirmNewPassword];
}

final changePasswordUsecaseProvider = Provider<ChangePasswordUsecase>((ref) {
  return ChangePasswordUsecase(authRepository: ref.read(authRepositoryProvider));
});

class ChangePasswordUsecase implements UsecaseWithParams<bool, ChangePasswordParam> {
  final IAuthRepository _authRepository;
  ChangePasswordUsecase({required IAuthRepository authRepository})
      : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(ChangePasswordParam params) {
    return _authRepository.changePassword(
      currentPassword: params.currentPassword,
      newPassword: params.newPassword,
      confirmNewPassword: params.confirmNewPassword,
    );
  }
}