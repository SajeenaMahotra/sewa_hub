import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String fullName;
  final String email;
  final String? profilePicture;

  const ProfileEntity({
    required this.fullName,
    required this.email,
    this.profilePicture,
  });

  @override
  List<Object?> get props => [
        fullName,
        email,
        profilePicture,
      ];
}