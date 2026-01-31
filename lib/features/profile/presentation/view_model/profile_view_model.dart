// lib/features/profile/presentation/viewmodel/profile_viewmodel.dart

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:sewa_hub/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:sewa_hub/features/profile/presentation/state/profile_state.dart';

// Provider
final profileViewModelProvider = NotifierProvider<ProfileViewModel, ProfileState>(() {
  return ProfileViewModel();
});

class ProfileViewModel extends Notifier<ProfileState> {
  late final GetProfileUsecase _getProfileUsecase;
  late final UpdateProfileUsecase _updateProfileUsecase;

  @override
  ProfileState build() {
    _getProfileUsecase = ref.read(getProfileUsecaseProvider);
    _updateProfileUsecase = ref.read(updateProfileUsecaseProvider);
    return const ProfileState();
  }

  Future<void> getProfile() async {
    state = state.copyWith(status: ProfileStatus.loading);
    
    final result = await _getProfileUsecase.call();
    
    result.fold(
      (failure) {
        state = state.copyWith(
          status: ProfileStatus.error,
          errorMessage: failure.toString(),
        );
      },
      (profileEntity) {
        state = state.copyWith(
          status: ProfileStatus.loaded,
          profileEntity: profileEntity,
        );
      },
    );
  }

  Future<void> updateProfile({
  required String fullName,
  required String email,
  File? imageFile,
}) async {
  state = state.copyWith(status: ProfileStatus.loading);
  
  final params = UpdateProfileUsecaseParam(
    fullName: fullName,
    email: email,
    imageFile: imageFile,
  );
  
  final result = await _updateProfileUsecase.call(params);
  
  result.fold(
    (failure) {
      state = state.copyWith(
        status: ProfileStatus.error,
        errorMessage: failure.toString(),
      );
    },
    (isUpdated) async {
      if (isUpdated) {
        // Set updated status first so snackbar can show
        state = state.copyWith(status: ProfileStatus.updated);
        
        // Wait a bit for the snackbar to appear
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Then refresh profile
        await getProfile();
      } else {
        state = state.copyWith(
          status: ProfileStatus.error,
          errorMessage: "Update failed",
        );
      }
    },
  );
}
}