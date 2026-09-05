import 'offline_models.dart';
import 'offline_storage.dart';

class OfflineRepository {
  final OfflineStorage storage;
  final CachePolicy policy;

  OfflineRepository({
    OfflineStorage? storage,
    this.policy = const CachePolicy(),
  }) : storage = storage ?? MemoryOfflineStorage();

  Future<void> put<T>({
    required String resourceKey,
    required T value,
    required Map<String, Object?> Function(T value) serialize,
    CacheSource source = CacheSource.rest,
    DateTime? fetchedAt,
    DateTime? confirmedAt,
    CacheConfirmation confirmation = CacheConfirmation.live,
    Duration? freshnessWindow,
  }) async {
    final envelope = CacheEnvelope<T>(
      resourceKey: resourceKey,
      value: value,
      source: source,
      fetchedAt: fetchedAt ?? DateTime.now(),
      confirmedAt: confirmedAt ?? DateTime.now(),
      freshnessWindow: freshnessWindow ?? policy.forResource(resourceKey),
      confirmation: confirmation,
    );
    await storage.write(resourceKey, {
      ...envelope.metadata(),
      'value': serialize(value),
    });
  }

  Future<bool> putIfNewer<T>({
    required String resourceKey,
    required T value,
    required Map<String, Object?> Function(T value) serialize,
    required DateTime confirmedAt,
    CacheSource source = CacheSource.rest,
    CacheConfirmation confirmation = CacheConfirmation.live,
  }) async {
    final existing = await get(resourceKey);
    if (existing?.confirmedAt != null &&
        !confirmedAt.isAfter(existing!.confirmedAt!)) {
      return false;
    }
    await put(
      resourceKey: resourceKey,
      value: value,
      serialize: serialize,
      source: source,
      confirmedAt: confirmedAt,
      confirmation: confirmation,
    );
    return true;
  }

  Future<CacheEnvelope<Map<String, Object?>>?> get(String resourceKey) async {
    final raw = await storage.read(resourceKey);
    if (raw == null) return null;
    final fetchedAt = DateTime.tryParse(raw['fetchedAt']?.toString() ?? '');
    if (fetchedAt == null || raw['schemaVersion'] != CacheEnvelope.currentSchemaVersion) {
      await storage.delete(resourceKey);
      return null;
    }
    final source = _enumValue(CacheSource.values, raw['source'], CacheSource.cache);
    final confirmation = _enumValue(
      CacheConfirmation.values,
      raw['confirmation'],
      CacheConfirmation.unconfirmed,
    );
    final value = raw['value'];
    if (value is! Map) return null;
    return CacheEnvelope<Map<String, Object?>>(
      resourceKey: resourceKey,
      schemaVersion: CacheEnvelope.currentSchemaVersion,
      value: Map<String, Object?>.from(value),
      source: source,
      fetchedAt: fetchedAt,
      confirmedAt: DateTime.tryParse(raw['confirmedAt']?.toString() ?? ''),
      freshnessWindow: Duration(
        seconds: int.tryParse(raw['freshnessSeconds']?.toString() ?? '') ??
            policy.forResource(resourceKey).inSeconds,
      ),
      confirmation: confirmation,
    );
  }

  Future<void> invalidate(String resourceKey) => storage.delete(resourceKey);

  T _enumValue<T extends Enum>(List<T> values, Object? raw, T fallback) {
    return values.firstWhere(
      (value) => value.name == raw?.toString(),
      orElse: () => fallback,
    );
  }
}
