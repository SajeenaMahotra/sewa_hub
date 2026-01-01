import 'dart:core';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/core/error/failures.dart';
import 'package:sewa_hub/core/usecases/app_usecase.dart';
import 'package:sewa_hub/features/auth/data/repositories/auth_repository.dart';
import 'package:sewa_hub/features/auth/domain/entities/auth_entity.dart';
import 'package:sewa_hub/features/auth/domain/repositories/auth_repository.dart';

class LoginUsecaseParam extends Equatable {
  final String email;
  final String password;

  const LoginUsecaseParam({
    required this.email,
    required this.password,
  });
  @override
  List<Object?> get props => [ 
    email,
    password,
  ];
}

//Provider for LoginUsecase
final loginUsecaseProvider = Provider<LoginUsecase>((ref){
  final authRepository = ref.watch(authRepositoryProvider);
  return LoginUsecase(authRepository: authRepository);
});

class LoginUsecase implements UsecaseWithParams<AuthEntity, LoginUsecaseParam> {
  final IAuthRepository _authRepository;

  LoginUsecase({required IAuthRepository authRepository})
      : _authRepository = authRepository;
  @override
  Future<Either<Failure, AuthEntity>> call(LoginUsecaseParam params) {
    return _authRepository.login(params.email, params.password);
  }

}
  
