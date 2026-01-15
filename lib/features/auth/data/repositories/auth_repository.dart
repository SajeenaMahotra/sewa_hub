import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/core/error/failures.dart';
import 'package:sewa_hub/core/services/connectivity/network_info.dart';
import 'package:sewa_hub/features/auth/data/datasources/auth_datasource.dart';
import 'package:sewa_hub/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:sewa_hub/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:sewa_hub/features/auth/data/models/auth_hive_model.dart';
import 'package:sewa_hub/features/auth/domain/entities/auth_entity.dart';
import 'package:sewa_hub/features/auth/domain/repositories/auth_repository.dart';

//provider
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final authDatasource = ref.read(authLocalDatasourceProvider);
  final authRemoteDatasource = ref.read(authRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  return AuthRepository(
    authDatasource: authDatasource,
    authRemoteDataSource: authRemoteDatasource,
    networkInfo: networkInfo,
  );
});

class AuthRepository implements IAuthRepository {
  final IAuthLocalDatasource _authDatasource;
  final IAuthRemoteDataSource _authRemoteDataSource;
  final NetworkInfo _networkInfo;

  AuthRepository({
    required IAuthLocalDatasource authDatasource,
    required IAuthRemoteDataSource authRemoteDataSource,
    required NetworkInfo networkInfo,
  }) : _authDatasource = authDatasource,
       _authRemoteDataSource = authRemoteDataSource,
       _networkInfo = networkInfo;

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
