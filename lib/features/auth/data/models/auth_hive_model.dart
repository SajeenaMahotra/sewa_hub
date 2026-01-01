import 'dart:core';

import 'package:hive/hive.dart';
import 'package:sewa_hub/core/constants/hive_table_constants.dart';
import 'package:sewa_hub/features/auth/domain/entities/auth_entity.dart';
import 'package:uuid/uuid.dart';

part 'auth_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.authTypeId)
class AuthHiveModel extends HiveObject{

  @HiveField(0)
  final String? authId;
  @HiveField(1)
  final String fullName;
  @HiveField(2)
  final String email;
  @HiveField(3)
  final String? password;
  @HiveField(4)
  final String? profilePicture;

  AuthHiveModel({
    String? authId,
    required this.fullName,
    required this.email,
    this.password,
    this.profilePicture,
  }) : authId = authId ?? Uuid().v4();

  //From Entity
  factory AuthHiveModel.fromEntity(AuthEntity authEntity){
    return AuthHiveModel(
      authId: authEntity.authId,
      fullName: authEntity.fullName,
      email:  authEntity.email,
      password: authEntity.password,
      profilePicture: authEntity.profilePicture,
    );
  }

  //To Entity
  AuthEntity toEntity(){
    return AuthEntity(
      authId: authId!,
      fullName: fullName,
      email: email,
      password: password,
      profilePicture: profilePicture,
    );
  }

 
}