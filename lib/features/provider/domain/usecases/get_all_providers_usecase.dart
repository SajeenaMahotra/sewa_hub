import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/core/error/failures.dart';
import 'package:sewa_hub/core/usecases/app_usecase.dart';
import 'package:sewa_hub/features/provider/data/repositories/provider_repository.dart';
import 'package:sewa_hub/features/provider/domain/repositories/provider_repository.dart';

class GetAllProvidersParams extends Equatable {
  final int page;
  final int size;
  final String? categoryId;

  const GetAllProvidersParams({
    this.page = 1,
    this.size = 12,
    this.categoryId,
  });

  @override
  List<Object?> get props => [page, size, categoryId];
}

final getAllProvidersUsecaseProvider = Provider<GetAllProvidersUsecase>((ref) {
  final repository = ref.watch(providerRepositoryProvider);
  return GetAllProvidersUsecase(providerRepository: repository);
});

class GetAllProvidersUsecase
    implements UsecaseWithParams<Map<String, dynamic>, GetAllProvidersParams> {
  final IProviderRepository _providerRepository;

  GetAllProvidersUsecase({required IProviderRepository providerRepository})
      : _providerRepository = providerRepository;

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
      GetAllProvidersParams params) {
    return _providerRepository.getAllProviders(
      page: params.page,
      size: params.size,
      categoryId: params.categoryId,
    );
  }
}