import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/core/error/failures.dart';
import 'package:sewa_hub/core/usecases/app_usecase.dart';
import 'package:sewa_hub/features/auth/data/repositories/auth_repository.dart';
import 'package:sewa_hub/features/auth/domain/entities/auth_entity.dart';
import 'package:sewa_hub/features/auth/domain/repositories/auth_repository.dart';

class RegisterUsecaseParam extends Equatable {
  final String fullName;
  final String email;
  final String password;

  const RegisterUsecaseParam({
    required this.fullName,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [
    fullName,
    email,
    password,
  ];
}

//provider for RegisterUsecase
final registerUsecaseProvider = Provider<RegisterUsecase>((ref){
  final authRepository = ref.watch(authRepositoryProvider);
  return RegisterUsecase(authRepository: authRepository);
});

class RegisterUsecase implements UsecaseWithParams<bool, RegisterUsecaseParam> {

  final IAuthRepository _authRepository;

  RegisterUsecase({required IAuthRepository authRepository})
      : _authRepository = authRepository;
  @override
  Future<Either<Failure, bool>> call(RegisterUsecaseParam params) {
    final entity = AuthEntity(
      fullName: params.fullName,
      email: params.email,
      password: params.password
    );
    return _authRepository.register(entity);
  }
}