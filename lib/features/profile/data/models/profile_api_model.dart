import 'package:sewa_hub/features/profile/domain/entities/profile_entity.dart';

class ProfileApiModel{
  final String fullName;
  final String email;
  final String? profilePicture;

  ProfileApiModel({
    required this.fullName,
    required this.email,
    this.profilePicture,
  });

  //toJson
  Map<String, dynamic> toJson() {
    return {
      "fullname": fullName,
      "email": email,
      "profilePicture": profilePicture,
    };
  }

  //fromJson
  factory ProfileApiModel.fromJson(Map<String, dynamic> json) {
    return ProfileApiModel(
      fullName: json["fullname"] as String? ?? "",
      email: json["email"] as String? ?? "",
      profilePicture: json["profilePicture"] as String?,
    );
  }

  //toEntity
  ProfileEntity toEntity() {
    return ProfileEntity(
      fullName: fullName,
      email: email,
      profilePicture: profilePicture,
    );
  }

  //fromEntity
  factory ProfileApiModel.fromEntity(ProfileEntity entity){
    return ProfileApiModel(
      fullName: entity.fullName,
      email: entity.email,
      profilePicture: entity.profilePicture,
    );
  }

}