// lib/features/profile/domain/usecases/update_profile_usecase.dart

import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/core/error/failures.dart';
import 'package:sewa_hub/core/usecases/app_usecase.dart';
import 'package:sewa_hub/features/profile/data/repositories/profile_repository.dart';
import 'package:sewa_hub/features/profile/domain/entities/profile_entity.dart';
import 'package:sewa_hub/features/profile/domain/repositories/profile_repository.dart';

class UpdateProfileUsecaseParam extends Equatable {
  final String fullName;
  final String email;
  final File? imageFile;

  const UpdateProfileUsecaseParam({
    required this.fullName,
    required this.email,
    this.imageFile,
  });

  @override
  List<Object?> get props => [
        fullName,
        email,
        imageFile,
      ];
}

// Provider for UpdateProfileUsecase
final updateProfileUsecaseProvider = Provider<UpdateProfileUsecase>((ref) {
  final profileRepository = ref.watch(profileRepositoryProvider);
  return UpdateProfileUsecase(profileRepository: profileRepository);
});

class UpdateProfileUsecase implements UsecaseWithParams<bool, UpdateProfileUsecaseParam> {
  final IProfileRepository _profileRepository;

  UpdateProfileUsecase({required IProfileRepository profileRepository})
      : _profileRepository = profileRepository;

  @override
  Future<Either<Failure, bool>> call(UpdateProfileUsecaseParam params) {
    final entity = ProfileEntity(
      fullName: params.fullName,
      email: params.email,
      profilePicture: null, // Will be updated via imageFile
    );
    return _profileRepository.updateProfile(entity, imageFile: params.imageFile); // ← ADD imageFile here!
  }
}