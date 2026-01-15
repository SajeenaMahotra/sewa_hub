import 'package:sewa_hub/features/auth/domain/entities/auth_entity.dart';


class AuthApiModel {
  final String? authId;
  final String fullName;
  final String email;
  String? password;
  String? confirmPassword;
  //final String? role;
  final String? profilePicture;

  AuthApiModel({
    this.authId,
    required this.fullName,
    required this.email,
    this.password,
    this.confirmPassword,
    //this.role,
    this.profilePicture,
  });

  //toJson
  Map<String, dynamic> toJson() {
    return {
      "fullname": fullName,
      "email": email,
      "password": password,
      "confirmPassword": confirmPassword,
      //"role": role,
      "profilePicture": profilePicture,
    };
  }

  //fromJson
  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    return AuthApiModel(
      authId: json["_id"] as String?,
      fullName: json["fullname"] as String? ?? "",
      email: json["email"] as String? ?? "",
      password: json["password"] as String? ?? "",
      //role: json["role"] as String?,
      profilePicture: json["profilePicture"] as String?,
    );
  }

  //toEntity
  AuthEntity toEntity() {
    return AuthEntity(
      authId: authId,
      fullName: fullName,
      email: email,
      //role: role,
      profilePicture: profilePicture,);
  }

  //fromEntity
  factory AuthApiModel.fromEntity(AuthEntity entity){
    return AuthApiModel(
      fullName: entity.fullName,
      email: entity.email,
      password: entity.password,
      confirmPassword: entity.password, 
      //role: entity.role,
      profilePicture: entity.profilePicture,
    );
  }

  //toEntityList
  static List<AuthEntity> toEntityList(List<AuthApiModel>models){
    return models.map((model) => model.toEntity()).toList();
  }
}
