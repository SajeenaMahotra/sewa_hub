import 'package:equatable/equatable.dart';

class ProviderUserEntity extends Equatable {
  final String id;
  final String fullname;
  final String email;
  final String? imageUrl;

  const ProviderUserEntity({
    required this.id,
    required this.fullname,
    required this.email,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [id, fullname, email, imageUrl];
}

class ProviderCategoryEntity extends Equatable {
  final String id;
  final String categoryName;

  const ProviderCategoryEntity({required this.id, required this.categoryName});

  @override
  List<Object?> get props => [id, categoryName];
}

class ProviderEntity extends Equatable {
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
  final ProviderUserEntity? user;
  final ProviderCategoryEntity? category;

  const ProviderEntity({
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

  @override
  List<Object?> get props => [
        id,
        experienceYears,
        isVerified,
        rating,
        reviewCount,
        bio,
        phone,
        address,
        imageUrl,
        pricePerHour,
        user,
        category,
      ];
}