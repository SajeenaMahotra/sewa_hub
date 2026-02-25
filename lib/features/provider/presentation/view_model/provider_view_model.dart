import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/features/provider/domain/entities/provider_entity.dart';
import 'package:sewa_hub/features/provider/domain/usecases/get_all_providers_usecase.dart';
import 'package:sewa_hub/features/provider/domain/usecases/get_provider_by_id_usecase.dart';
import 'package:sewa_hub/features/provider/presentation/state/provider_state.dart';

final providerViewModelProvider =
    NotifierProvider<ProviderViewModel, ProviderState>(() {
  return ProviderViewModel();
});

class ProviderViewModel extends Notifier<ProviderState> {
  late final GetAllProvidersUsecase _getAllProvidersUsecase;
  late final GetProviderByIdUsecase _getProviderByIdUsecase;

  static const int _pageSize = 12;
  String? _selectedCategoryId;

  @override
  ProviderState build() {
    _getAllProvidersUsecase = ref.read(getAllProvidersUsecaseProvider);
    _getProviderByIdUsecase = ref.read(getProviderByIdUsecaseProvider);
    return const ProviderState();
  }

  Future<void> loadProviders({String? categoryId, bool reset = false}) async {
    if (reset) {
      _selectedCategoryId = categoryId;
      state = state.copyWith(
        status: ProviderStatus.loading,
        providers: [],
        currentPage: 1,
        hasMore: true,
        errorMessage: null,
      );
    } else {
      // Pagination - don't reload if already loading or no more pages
      if (state.status == ProviderStatus.loadingMore) return;
      if (!state.hasMore) return;
      state = state.copyWith(status: ProviderStatus.loadingMore);
    }

    final currentPage = reset ? 1 : state.currentPage;

    final result = await _getAllProvidersUsecase.call(
      GetAllProvidersParams(
        page: currentPage,
        size: _pageSize,
        categoryId: _selectedCategoryId,
      ),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: ProviderStatus.error,
          errorMessage: failure.toString(),
        );
      },
      (data) {
        final newProviders = data['providers'] as List<ProviderEntity>;
        final total = data['total'] as int;
        final allProviders = reset
            ? newProviders
            : [...state.providers, ...newProviders];

        state = state.copyWith(
          status: ProviderStatus.loaded,
          providers: allProviders,
          total: total,
          currentPage: currentPage + 1,
          hasMore: allProviders.length < total,
        );
      },
    );
  }

  Future<void> loadMore() async {
    await loadProviders();
  }

  Future<void> filterByCategory(String? categoryId) async {
    await loadProviders(categoryId: categoryId, reset: true);
  }

  Future<void> getProviderById(String id) async {
    state = state.copyWith(
      status: ProviderStatus.detailLoading,
      errorMessage: null,
    );

    final result = await _getProviderByIdUsecase.call(id);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: ProviderStatus.error,
          errorMessage: failure.toString(),
        );
      },
      (provider) {
        state = state.copyWith(
          status: ProviderStatus.detailLoaded,
          selectedProvider: provider,
        );
      },
    );
  }
}