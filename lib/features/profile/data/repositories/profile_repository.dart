import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/core/error/failures.dart';
import 'package:sewa_hub/features/profile/data/datasources/remote/profile_remote_datasource.dart';

import 'package:sewa_hub/features/profile/domain/entities/profile_entity.dart';
import 'package:sewa_hub/features/profile/domain/repositories/profile_repository.dart';

final profileRepositoryProvider = Provider<IProfileRepository>((ref) {
  final remoteDataSource = ref.watch(profileRemoteDataSourceProvider);
  return ProfileRepository(remoteDataSource: remoteDataSource);
});

class ProfileRepository implements IProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;

  ProfileRepository({required ProfileRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, ProfileEntity>> getProfile() {
    return _remoteDataSource.getProfile().then((result) {
      return result.map((apiModel) => apiModel.toEntity());
    });
  }

  @override
  Future<Either<Failure, bool>> updateProfile(ProfileEntity profile) {
    return _remoteDataSource.updateProfile(profile);
  }
}