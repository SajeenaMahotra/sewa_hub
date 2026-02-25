import 'package:equatable/equatable.dart';
import 'package:sewa_hub/features/provider/domain/entities/provider_entity.dart';

enum ProviderStatus {
  initial,
  loading,
  loaded,
  loadingMore,
  detailLoading,
  detailLoaded,
  error,
}

class ProviderState extends Equatable {
  final ProviderStatus status;
  final List<ProviderEntity> providers;
  final ProviderEntity? selectedProvider;
  final int total;
  final int currentPage;
  final bool hasMore;
  final String? errorMessage;

  const ProviderState({
    this.status = ProviderStatus.initial,
    this.providers = const [],
    this.selectedProvider,
    this.total = 0,
    this.currentPage = 1,
    this.hasMore = true,
    this.errorMessage,
  });

  ProviderState copyWith({
    ProviderStatus? status,
    List<ProviderEntity>? providers,
    ProviderEntity? selectedProvider,
    int? total,
    int? currentPage,
    bool? hasMore,
    String? errorMessage,
  }) {
    return ProviderState(
      status: status ?? this.status,
      providers: providers ?? this.providers,
      selectedProvider: selectedProvider ?? this.selectedProvider,
      total: total ?? this.total,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        providers,
        selectedProvider,
        total,
        currentPage,
        hasMore,
        errorMessage,
      ];
}