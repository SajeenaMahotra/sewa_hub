import 'package:equatable/equatable.dart';
import 'package:sewa_hub/features/profile/domain/entities/profile_entity.dart';

enum ProfileStatus {
  initial,
  loading,
  loaded,
  updated,
  error,
}

class ProfileState extends Equatable {
  final ProfileStatus status;
  final ProfileEntity? profileEntity;
  final String? errorMessage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profileEntity,
    this.errorMessage,
  });

  // copyWith
  ProfileState copyWith({
    ProfileStatus? status,
    ProfileEntity? profileEntity,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profileEntity: profileEntity ?? this.profileEntity,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, profileEntity, errorMessage];
}