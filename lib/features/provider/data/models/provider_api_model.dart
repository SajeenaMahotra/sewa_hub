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
      id: json['_id'] ?? '',
      fullname: json['fullname'] as String? ?? '',
      email: json['email'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
    );
  }

  ProviderUserEntity toEntity() => ProviderUserEntity(
        id: id,
        fullname: fullname,
        email: email,
        imageUrl: imageUrl,
      );
}

class ProviderCategoryApiModel {
  final String id;
  final String categoryName;

  ProviderCategoryApiModel({required this.id, required this.categoryName});

  factory ProviderCategoryApiModel.fromJson(Map<String, dynamic> json) {
    return ProviderCategoryApiModel(
      id: json['_id'] ?? '',
      categoryName: json['category_name'] as String? ?? '',
    );
  }

  ProviderCategoryEntity toEntity() => ProviderCategoryEntity(
        id: id,
        categoryName: categoryName,
      );
}

class ProviderApiModel {
  final String id;
  final int experienceYears;
  final int isVerified;
  final double rating;
  final int reviewCount;
  final String? bio;
  final String? phone;
  final String? address;
  final String? imageUrl;
  final double pricePerHour;
  final ProviderUserApiModel? user;
  final ProviderCategoryApiModel? category;

  ProviderApiModel({
    required this.id,
    required this.experienceYears,
    required this.isVerified,
    required this.rating,
    required this.reviewCount,
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
      id: json['_id'] ?? '',
      experienceYears: (json['experience_years'] ?? 0).toInt(),
      isVerified: (json['is_verified'] ?? 0).toInt(),
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: (json['review_count'] ?? 0).toInt(),
      bio: json['bio'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      imageUrl: json['imageUrl'] as String?,
      pricePerHour: (json['price_per_hour'] ?? 0).toDouble(),
      user: json['Useruser_id'] != null && json['Useruser_id'] is Map
          ? ProviderUserApiModel.fromJson(
              json['Useruser_id'] as Map<String, dynamic>)
          : null,
      category: json['ServiceCategorycatgeory_id'] != null &&
              json['ServiceCategorycatgeory_id'] is Map
          ? ProviderCategoryApiModel.fromJson(
              json['ServiceCategorycatgeory_id'] as Map<String, dynamic>)
          : null,
    );
  }

  ProviderEntity toEntity() => ProviderEntity(
        id: id,
        experienceYears: experienceYears,
        isVerified: isVerified,
        rating: rating,
        reviewCount: reviewCount,
        bio: bio,
        phone: phone,
        address: address,
        imageUrl: imageUrl,
        pricePerHour: pricePerHour,
        user: user?.toEntity(),
        category: category?.toEntity(),
      );
}