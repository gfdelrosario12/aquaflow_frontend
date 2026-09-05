enum ConnectivityState {
  online,
  offline,
  degraded,
  synchronizing,
  recovery,
}

enum CacheSource { rest, realtime, cache }

enum CacheConfirmation { live, recent, stale, unconfirmed }

enum CacheAvailability { fresh, stale, expired, missing }

class CacheEnvelope<T> {
  static const currentSchemaVersion = 1;

  final String resourceKey;
  final int schemaVersion;
  final T value;
  final CacheSource source;
  final DateTime fetchedAt;
  final DateTime? confirmedAt;
  final Duration freshnessWindow;
  final CacheConfirmation confirmation;

  const CacheEnvelope({
    required this.resourceKey,
    this.schemaVersion = currentSchemaVersion,
    required this.value,
    required this.source,
    required this.fetchedAt,
    this.confirmedAt,
    required this.freshnessWindow,
    required this.confirmation,
  });

  CacheAvailability availability({DateTime? now}) {
    final currentTime = now ?? DateTime.now();
    final age = currentTime.difference(fetchedAt);
    if (age.isNegative || age <= freshnessWindow) return CacheAvailability.fresh;
    if (age <= freshnessWindow * 3) return CacheAvailability.stale;
    return CacheAvailability.expired;
  }

  bool get canDisplay => availability() != CacheAvailability.expired;

  bool get isLiveConfirmed =>
      source != CacheSource.cache && confirmation == CacheConfirmation.live;

  CacheEnvelope<T> asCached() {
    return CacheEnvelope<T>(
      resourceKey: resourceKey,
      schemaVersion: schemaVersion,
      value: value,
      source: CacheSource.cache,
      fetchedAt: fetchedAt,
      confirmedAt: confirmedAt,
      freshnessWindow: freshnessWindow,
      confirmation: confirmation == CacheConfirmation.live
          ? CacheConfirmation.recent
          : confirmation,
    );
  }

  Map<String, Object?> metadata() => {
        'resourceKey': resourceKey,
        'schemaVersion': schemaVersion,
        'source': source.name,
        'fetchedAt': fetchedAt.toIso8601String(),
        'confirmedAt': confirmedAt?.toIso8601String(),
        'freshnessSeconds': freshnessWindow.inSeconds,
        'confirmation': confirmation.name,
        'availability': availability().name,
      };
}

class CachePolicy {
  final Duration field;
  final Duration measurement;
  final Duration history;
  final Duration analytics;
  final Duration alerts;
  final Duration devices;
  final Duration irrigation;

  const CachePolicy({
    this.field = const Duration(minutes: 15),
    this.measurement = const Duration(minutes: 15),
    this.history = const Duration(hours: 24),
    this.analytics = const Duration(hours: 6),
    this.alerts = const Duration(minutes: 30),
    this.devices = const Duration(minutes: 5),
    this.irrigation = const Duration(minutes: 1),
  });

  Duration forResource(String key) {
    if (key.startsWith('measurement:')) return measurement;
    if (key.startsWith('history:')) return history;
    if (key.startsWith('analytics:')) return analytics;
    if (key.startsWith('alert:')) return alerts;
    if (key.startsWith('device:') || key == 'gateway') return devices;
    if (key == 'irrigation') return irrigation;
    return field;
  }
}
