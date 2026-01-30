// lib/features/profile/domain/usecases/get_profile_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/core/error/failures.dart';
import 'package:sewa_hub/core/usecases/app_usecase.dart';
import 'package:sewa_hub/features/profile/data/repositories/profile_repository.dart';
import 'package:sewa_hub/features/profile/domain/entities/profile_entity.dart';
import 'package:sewa_hub/features/profile/domain/repositories/profile_repository.dart';

// Provider for GetProfileUsecase
final getProfileUsecaseProvider = Provider<GetProfileUsecase>((ref) {
  final profileRepository = ref.watch(profileRepositoryProvider);
  return GetProfileUsecase(profileRepository: profileRepository);
});

class GetProfileUsecase implements UsecaseWithoutParams<ProfileEntity> {
  final IProfileRepository _profileRepository;

  GetProfileUsecase({required IProfileRepository profileRepository})
      : _profileRepository = profileRepository;

  @override
  Future<Either<Failure, ProfileEntity>> call() {
    return _profileRepository.getProfile();
  }
}