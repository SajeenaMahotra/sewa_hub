import 'package:dartz/dartz.dart';
import 'package:sewa_hub/core/error/failures.dart';
import 'package:sewa_hub/features/provider/domain/entities/provider_entity.dart';

abstract class IProviderRepository {
  Future<Either<Failure, Map<String, dynamic>>> getAllProviders({
    int page = 1,
    int size = 12,
    String? categoryId,
  });

  Future<Either<Failure, ProviderEntity>> getProviderById(String id);
}