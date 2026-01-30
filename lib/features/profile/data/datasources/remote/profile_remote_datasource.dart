import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/core/api/api_client.dart'; // Import this
import 'package:sewa_hub/core/error/failures.dart';
import 'package:sewa_hub/features/profile/data/models/profile_api_model.dart';
import 'package:sewa_hub/features/profile/domain/entities/profile_entity.dart';

final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider); // Use apiClientProvider
  return ProfileRemoteDataSource(apiClient: apiClient);
});

class ProfileRemoteDataSource {
  final ApiClient _apiClient;

  ProfileRemoteDataSource({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<Either<Failure, ProfileApiModel>> getProfile() async {
    try {
      final response = await _apiClient.get('/profile'); // Adjust endpoint
      
      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return Right(ProfileApiModel.fromJson(data));
      }
      return Left(NetworkFailure(error: response.data['message'] ?? 'Failed to get profile'));
    } catch (e) {
      return Left(NetworkFailure(error: e.toString()));
    }
  }

  Future<Either<Failure, bool>> updateProfile(ProfileEntity profile) async {
    try {
      final model = ProfileApiModel(
        fullName: profile.fullName,
        email: profile.email,
        profilePicture: profile.profilePicture,
      );

      final response = await _apiClient.put('/profile', data: model.toJson()); // Adjust endpoint
      
      if (response.data['success'] == true) {
        return const Right(true);
      }
      return Left(NetworkFailure(error: response.data['message'] ?? 'Failed to update profile'));
    } catch (e) {
      return Left(NetworkFailure(error: e.toString()));
    }
  }
}