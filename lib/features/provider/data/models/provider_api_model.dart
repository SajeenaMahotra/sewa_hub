import 'package:sewa_hub/features/provider/domain/entities/provider_entity.dart';

class ProviderUserApiModel {
  final String id;
  final String fullname;
  final String email;
  final String? imageUrl;

  ProviderUserApiModel({
    required this.id,
    required this.fullname,
    required this.email,
    this.imageUrl,
  });

  factory ProviderUserApiModel.fromJson(Map<String, dynamic> json) {
    return ProviderUserApiModel(
      id:       json['_id'] as String? ?? '',
      fullname: json['fullname'] as String? ?? '',
      email:    json['email'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
    );
  }

  ProviderUserEntity toEntity() => ProviderUserEntity(
        id:       id,
        fullname: fullname,
        email:    email,
        imageUrl: imageUrl,
      );
}

class ProviderCategoryApiModel {
  final String id;
  final String categoryName;

  ProviderCategoryApiModel({required this.id, required this.categoryName});

  factory ProviderCategoryApiModel.fromJson(Map<String, dynamic> json) {
    return ProviderCategoryApiModel(
      id:           json['_id'] as String? ?? '',
      categoryName: json['category_name'] as String? ?? '',
    );
  }

  ProviderCategoryEntity toEntity() => ProviderCategoryEntity(
        id:           id,
        categoryName: categoryName,
      );
}

class ProviderApiModel {
  final String  id;
  final int     experienceYears;
  final int     isVerified;
  final double  rating;
  final int     ratingCount;      // ← was reviewCount
  final String? bio;
  final String? phone;
  final String? address;
  final String? imageUrl;
  final double  pricePerHour;
  final ProviderUserApiModel?     user;
  final ProviderCategoryApiModel? category;

  ProviderApiModel({
    required this.id,
    required this.experienceYears,
    required this.isVerified,
    required this.rating,
    required this.ratingCount,    // ← was reviewCount
    this.bio,
    this.phone,
    this.address,
    this.imageUrl,
    required this.pricePerHour,
    this.user,
    this.category,
  });

  factory ProviderApiModel.fromJson(Map<String, dynamic> json) {
    return ProviderApiModel(
      id:              json['_id'] as String? ?? '',
      experienceYears: (json['experience_years'] as num?)?.toInt() ?? 0,
      isVerified:      (json['is_verified'] as num?)?.toInt() ?? 0,
      rating:          (json['rating'] as num?)?.toDouble() ?? 0.0,
      ratingCount:     (json['ratingCount'] as num?)?.toInt() ?? 0,
      bio:             json['bio'] as String?,
      phone:           json['phone'] as String?,
      address:         json['address'] as String?,
      imageUrl:        json['imageUrl'] as String?,
      pricePerHour:    (json['price_per_hour'] as num?)?.toDouble() ?? 0.0,
      user: json['Useruser_id'] is Map<String, dynamic>
          ? ProviderUserApiModel.fromJson(
              json['Useruser_id'] as Map<String, dynamic>)
          : null,
      category: json['ServiceCategorycatgeory_id'] is Map<String, dynamic>
          ? ProviderCategoryApiModel.fromJson(
              json['ServiceCategorycatgeory_id'] as Map<String, dynamic>)
          : null,
    );
  }

  ProviderEntity toEntity() => ProviderEntity(
        id:              id,
        experienceYears: experienceYears,
        isVerified:      isVerified,
        rating:          rating,
        ratingCount:     ratingCount,
        bio:             bio,
        phone:           phone,
        address:         address,
        imageUrl:        imageUrl,
        pricePerHour:    pricePerHour,
        user:            user?.toEntity(),
        category:        category?.toEntity(),
      );
}