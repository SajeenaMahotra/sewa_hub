import 'package:hive/hive.dart';
import 'package:sewa_hub/core/constants/hive_table_constants.dart';
import 'package:sewa_hub/features/profile/domain/entities/profile_entity.dart';

part 'profile_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.profileTypeId)
class ProfileHiveModel extends HiveObject {
  @HiveField(0)
  final String fullName;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String? profilePicture;

  ProfileHiveModel({
    required this.fullName,
    required this.email,
    this.profilePicture,
  });

  // From Entity
  factory ProfileHiveModel.fromEntity(ProfileEntity entity) {
    return ProfileHiveModel(
      fullName: entity.fullName,
      email: entity.email,
      profilePicture: entity.profilePicture,
    );
  }

  // To Entity
  ProfileEntity toEntity() {
    return ProfileEntity(
      fullName: fullName,
      email: email,
      profilePicture: profilePicture,
    );
  }
}