import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/core/error/failures.dart';
import 'package:sewa_hub/features/provider/data/datasources/remote/provider_remote_datasource.dart';
import 'package:sewa_hub/features/provider/domain/entities/provider_entity.dart';
import 'package:sewa_hub/features/provider/domain/repositories/provider_repository.dart';

final providerRepositoryProvider = Provider<IProviderRepository>((ref) {
  final remoteDataSource = ref.watch(providerRemoteDataSourceProvider);
  return ProviderRepositoryImpl(remoteDataSource: remoteDataSource);
});

class ProviderRepositoryImpl implements IProviderRepository {
  final ProviderRemoteDataSource _remoteDataSource;

  ProviderRepositoryImpl({required ProviderRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, Map<String, dynamic>>> getAllProviders({
    int page = 1,
    int size = 12,
    String? categoryId,
  }) async {
    final result = await _remoteDataSource.getAllProviders(
      page: page,
      size: size,
      categoryId: categoryId,
    );
    return result.map((data) {
      final providers = (data['providers'] as List)
          .map((model) => (model as dynamic).toEntity() as ProviderEntity)
          .toList();
      return {
        'providers': providers,
        'total': data['total'],
        'page': data['page'],
        'size': data['size'],
      };
    });
  }

  @override
  Future<Either<Failure, ProviderEntity>> getProviderById(String id) async {
    final result = await _remoteDataSource.getProviderById(id);
    return result.map((model) => model.toEntity());
  }
}