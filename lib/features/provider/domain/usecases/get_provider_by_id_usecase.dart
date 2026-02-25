import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/core/error/failures.dart';
import 'package:sewa_hub/core/usecases/app_usecase.dart';
import 'package:sewa_hub/features/provider/data/repositories/provider_repository.dart';
import 'package:sewa_hub/features/provider/domain/entities/provider_entity.dart';
import 'package:sewa_hub/features/provider/domain/repositories/provider_repository.dart';

final getProviderByIdUsecaseProvider = Provider<GetProviderByIdUsecase>((ref) {
  final repository = ref.watch(providerRepositoryProvider);
  return GetProviderByIdUsecase(providerRepository: repository);
});

class GetProviderByIdUsecase
    implements UsecaseWithParams<ProviderEntity, String> {
  final IProviderRepository _providerRepository;

  GetProviderByIdUsecase({required IProviderRepository providerRepository})
      : _providerRepository = providerRepository;

  @override
  Future<Either<Failure, ProviderEntity>> call(String params) {
    return _providerRepository.getProviderById(params);
  }
}