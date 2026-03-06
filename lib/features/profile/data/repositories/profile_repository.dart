import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/core/error/failures.dart';
import 'package:sewa_hub/core/services/connectivity/network_info.dart';
import 'package:sewa_hub/core/services/storage/user_session_service.dart';
import 'package:sewa_hub/features/profile/data/datasources/local/profile_local_datasource.dart';
import 'package:sewa_hub/features/profile/data/datasources/remote/profile_remote_datasource.dart';
import 'package:sewa_hub/features/profile/data/models/profile_hive_model.dart';
import 'package:sewa_hub/features/profile/domain/entities/profile_entity.dart';
import 'package:sewa_hub/features/profile/domain/repositories/profile_repository.dart';

final profileRepositoryProvider = Provider<IProfileRepository>((ref) {
  return ProfileRepository(
    remoteDataSource: ref.read(profileRemoteDataSourceProvider),
    localDataSource: ref.read(profileLocalDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
    userSessionService: ref.read(userSessionServiceProvider),
  );
});

class ProfileRepository implements IProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;
  final IProfileLocalDatasource _localDataSource;
  final NetworkInfo _networkInfo;
  final UserSessionService _userSessionService;

  ProfileRepository({
    required ProfileRemoteDataSource remoteDataSource,
    required IProfileLocalDatasource localDataSource,
    required NetworkInfo networkInfo,
    required UserSessionService userSessionService,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _networkInfo = networkInfo,
        _userSessionService = userSessionService;

  @override
  Future<Either<Failure, ProfileEntity>> getProfile() async {
    if (await _networkInfo.isConnected) {
      final result = await _remoteDataSource.getProfile();
      return result.fold(
        (failure) => _getFromCache(),
        (apiModel) async {
          final entity = apiModel.toEntity();
          await _localDataSource.saveProfile(ProfileHiveModel.fromEntity(entity));
          return Right(entity);
        },
      );
    } else {
      return _getFromCache();
    }
  }

  Future<Either<Failure, ProfileEntity>> _getFromCache() async {
    try {
      final email = _userSessionService.userEmail;
      if (email == null) {
        return const Left(LocalDatabaseFailure(message: 'No session found'));
      }
      final cached = await _localDataSource.getProfile(email);
      if (cached != null) return Right(cached.toEntity());
      return const Left(LocalDatabaseFailure(message: 'No cached profile found'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updateProfile(
    ProfileEntity profile, {
    File? imageFile,
  }) async {
    if (await _networkInfo.isConnected) {
      final result = await _remoteDataSource.updateProfile(profile, imageFile: imageFile);
      return result.fold(
        (failure) => Left(failure),
        (_) async {
          await _localDataSource.saveProfile(ProfileHiveModel.fromEntity(profile));
          return const Right(true);
        },
      );
    } else {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
  }
}