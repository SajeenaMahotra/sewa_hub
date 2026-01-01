import 'package:dartz/dartz.dart';
import 'package:sewa_hub/core/error/failures.dart';
import 'package:sewa_hub/features/auth/domain/entities/auth_entity.dart';

abstract interface class IAuthRepository{
  Future<Either<Failure, bool>> register(AuthEntity authEntity);
  Future<Either<Failure, AuthEntity>> login(String email, String password);
  Future<Either<Failure,AuthEntity>> getCurrentUser();
  Future<Either<Failure, bool>> logOut();
  
}