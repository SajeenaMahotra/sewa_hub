import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/core/error/failures.dart';
import 'package:sewa_hub/features/auth/data/datasources/auth_datasource.dart';
import 'package:sewa_hub/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:sewa_hub/features/auth/data/models/auth_hive_model.dart';
import 'package:sewa_hub/features/auth/domain/entities/auth_entity.dart';
import 'package:sewa_hub/features/auth/domain/repositories/auth_repository.dart';

//provider
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return AuthRepository(authDatasource: ref.watch(authLocalDatasourceProvider));
});

class AuthRepository implements IAuthRepository {
  final IAuthLocalDatasource _authDatasource;

  AuthRepository({required IAuthLocalDatasource authDatasource})
    : _authDatasource = authDatasource;

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    try {
      final user = await _authDatasource.getCurrentUser();
      //convert to entity
      final entity = user.toEntity();
      return Right(entity);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> logOut() async {
    try {
      final result = await _authDatasource.logOut();
      if (result) {
        return Right(true);
      }
      return Left(LocalDatabaseFailure(message: 'Failed to log out user'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login(
    String email,
    String password,
  ) async {
    try {
      final user = await _authDatasource.login(email, password);
      if (user != null) {
        //convert to entity
        final entity = user.toEntity();
        return Right(entity);
      }
      return Left(LocalDatabaseFailure(message: 'Invalid email or password'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> register(AuthEntity authEntity) async {
    try {
      //convert  to model
      final model = AuthHiveModel.fromEntity(authEntity);
      final result = await _authDatasource.register(model);
      if (result) {
        return Right(true);
      }
      return Left(LocalDatabaseFailure(message: 'Failed to register user'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }
}
