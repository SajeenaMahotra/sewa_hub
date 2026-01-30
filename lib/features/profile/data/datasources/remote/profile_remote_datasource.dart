import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/core/api/api_client.dart'; // Import this
import 'package:sewa_hub/core/error/failures.dart';
import 'package:sewa_hub/features/profile/data/models/profile_api_model.dart';
import 'package:sewa_hub/features/profile/domain/entities/profile_entity.dart';

final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((
  ref,
) {
  final apiClient = ref.watch(apiClientProvider); // Use apiClientProvider
  return ProfileRemoteDataSource(apiClient: apiClient);
});

class ProfileRemoteDataSource {
  final ApiClient _apiClient;

  ProfileRemoteDataSource({required ApiClient apiClient})
    : _apiClient = apiClient;


  Future<Either<Failure, ProfileApiModel>> getProfile() async {
    try {
      final response = await _apiClient.get('/auth/whoami'); // ← Changed

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return Right(ProfileApiModel.fromJson(data));
      }
      return Left(
        NetworkFailure(
          error: response.data['message'] ?? 'Failed to get profile',
        ),
      );
    } catch (e) {
      return Left(NetworkFailure(error: e.toString()));
    }
  }

  Future<Either<Failure, bool>> updateProfile(ProfileEntity profile, {File? imageFile}) async {
  try {
    FormData formData;
    
    if (imageFile != null) {
      // If there's an image, use multipart/form-data
      formData = FormData.fromMap({
        'fullname': profile.fullName,
        'email': profile.email,
        'image': await MultipartFile.fromFile( // ← Changed from 'imageUrl' to 'image'
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });
    } else {
      // No image, just send text data
      formData = FormData.fromMap({
        'fullname': profile.fullName,
        'email': profile.email,
      });
    }

    final response = await _apiClient.put('/auth/update-profile', data: formData);
    
    if (response.data['success'] == true) {
      return const Right(true);
    }
    return Left(NetworkFailure(error: response.data['message'] ?? 'Failed to update profile'));
  } catch (e) {
    return Left(NetworkFailure(error: e.toString()));
  }
}
}
