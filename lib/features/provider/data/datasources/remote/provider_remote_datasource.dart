import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/core/api/api_client.dart';
import 'package:sewa_hub/core/error/failures.dart';
import 'package:sewa_hub/features/provider/data/models/provider_api_model.dart';

final providerRemoteDataSourceProvider = Provider<ProviderRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProviderRemoteDataSource(apiClient: apiClient);
});

class ProviderRemoteDataSource {
  final ApiClient _apiClient;

  ProviderRemoteDataSource({required ApiClient apiClient})
      : _apiClient = apiClient;

  Future<Either<Failure, Map<String, dynamic>>> getAllProviders({
    int page = 1,
    int size = 12,
    String? categoryId,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'size': size,
      };
      if (categoryId != null && categoryId.isNotEmpty && categoryId != 'all') {
        queryParams['categoryId'] = categoryId;
      }

      final response = await _apiClient.get(
        '/provider',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final providers = (data['providers'] as List)
            .map((e) => ProviderApiModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return Right({
          'providers': providers,
          'total': data['total'] as int,
          'page': data['page'] as int,
          'size': data['size'] as int,
        });
      }

      return Left(
        NetworkFailure(
          error: response.data['message'] ?? 'Failed to fetch providers',
        ),
      );
    } catch (e) {
      return Left(NetworkFailure(error: e.toString()));
    }
  }

  Future<Either<Failure, ProviderApiModel>> getProviderById(String id) async {
    try {
      final response = await _apiClient.get('/provider/$id');

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return Right(ProviderApiModel.fromJson(data));
      }

      return Left(
        NetworkFailure(
          error: response.data['message'] ?? 'Provider not found',
        ),
      );
    } catch (e) {
      return Left(NetworkFailure(error: e.toString()));
    }
  }
}