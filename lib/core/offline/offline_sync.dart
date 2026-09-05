import 'dart:async';

import 'connectivity_service.dart';
import 'offline_models.dart';
import 'offline_repository.dart';

class OfflineResourceState<T> {
  final String resourceKey;
  final CacheEnvelope<T>? snapshot;
  final bool isLoading;
  final String? errorMessage;

  const OfflineResourceState({
    required this.resourceKey,
    this.snapshot,
    this.isLoading = false,
    this.errorMessage,
  });

  CacheAvailability? get availability => snapshot?.availability();
  bool get isStale => availability == CacheAvailability.stale;
  bool get isExpired => availability == CacheAvailability.expired;
}

typedef LiveResourceLoader<T> = Future<T> Function();
typedef ResourceSerializer<T> = Map<String, Object?> Function(T value);

class OfflineResource<T> {
  final String key;
  final OfflineRepository repository;
  final ConnectivityNotifier connectivity;
  final LiveResourceLoader<T> loadLive;
  final ResourceSerializer<T> serialize;
  OfflineResourceState<T> _state;

  OfflineResource({
    required this.key,
    required this.repository,
    required this.connectivity,
    required this.loadLive,
    required this.serialize,
  }) : _state = OfflineResourceState<T>(resourceKey: key);

  OfflineResourceState<T> get state => _state;

  Future<OfflineResourceState<T>> read() async {
    _state = OfflineResourceState<T>(resourceKey: key, isLoading: true, snapshot: _state.snapshot);
    final cached = await repository.get(key);
    if (connectivity.canReachBackend) {
      try {
        final value = await loadLive();
        final envelope = CacheEnvelope<T>(
          resourceKey: key,
          value: value,
          source: CacheSource.rest,
          fetchedAt: DateTime.now(),
          confirmedAt: DateTime.now(),
          freshnessWindow: repository.policy.forResource(key),
          confirmation: CacheConfirmation.live,
        );
        await repository.put(
          resourceKey: key,
          value: value,
          serialize: serialize,
          confirmation: CacheConfirmation.live,
        );
        _state = OfflineResourceState(resourceKey: key, snapshot: envelope);
        return _state;
      } catch (error) {
        _state = _cachedState(cached, error.toString());
        return _state;
      }
    }
    _state = _cachedState(cached, cached == null ? 'No offline cache is available.' : null);
    return _state;
  }

  OfflineResourceState<T> _cachedState(
    CacheEnvelope<Map<String, Object?>>? cached,
    String? error,
  ) {
    if (cached == null) {
      return OfflineResourceState(resourceKey: key, errorMessage: error);
    }
    final envelope = CacheEnvelope<T>(
      resourceKey: cached.resourceKey,
      value: cached.value as T,
      schemaVersion: cached.schemaVersion,
      source: CacheSource.cache,
      fetchedAt: cached.fetchedAt,
      confirmedAt: cached.confirmedAt,
      freshnessWindow: cached.freshnessWindow,
      confirmation: cached.confirmation == CacheConfirmation.live
          ? CacheConfirmation.recent
          : cached.confirmation,
    );
    return OfflineResourceState(resourceKey: key, snapshot: envelope, errorMessage: error);
  }
}

class OfflineRecoveryCoordinator {
  final ConnectivityNotifier connectivity;
  final List<Future<void> Function()> synchronizers;
  bool _running = false;

  OfflineRecoveryCoordinator({
    required this.connectivity,
    this.synchronizers = const [],
  });

  Future<void> synchronize() async {
    if (_running || !connectivity.canReachBackend) return;
    _running = true;
    connectivity.markSynchronizing();
    try {
      for (final synchronizer in synchronizers) {
        try {
          await synchronizer();
        } catch (_) {
          // Keep partial caches; a later retry can revalidate this resource.
        }
      }
      connectivity.markRecovery();
    } finally {
      _running = false;
    }
  }
}
