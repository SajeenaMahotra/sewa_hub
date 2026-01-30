// lib/features/profile/presentation/viewmodel/profile_viewmodel.dart

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
    String? profilePicture,
  }) async {
    state = state.copyWith(status: ProfileStatus.loading);
    
    final params = UpdateProfileUsecaseParam(
      fullName: fullName,
      email: email,
      profilePicture: profilePicture,
    );
    
    final result = await _updateProfileUsecase.call(params);
    
    result.fold(
      (failure) {
        state = state.copyWith(
          status: ProfileStatus.error,
          errorMessage: failure.toString(),
        );
      },
      (isUpdated) {
        if (isUpdated) {
          // Refresh profile after update
          getProfile();
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