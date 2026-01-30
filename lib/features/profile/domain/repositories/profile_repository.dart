import 'package:dartz/dartz.dart';
import 'package:sewa_hub/core/error/failures.dart';
import 'package:sewa_hub/features/profile/domain/entities/profile_entity.dart';

abstract class IProfileRepository {
  Future<Either<Failure, ProfileEntity>> getProfile();
  Future<Either<Failure, bool>> updateProfile(ProfileEntity profile);
}