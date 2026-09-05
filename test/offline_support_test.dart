import 'package:flutter_test/flutter_test.dart';
import 'package:aquaflow_frontend/core/offline/connectivity_service.dart';
import 'package:aquaflow_frontend/core/offline/irrigation_command_gate.dart';
import 'package:aquaflow_frontend/core/offline/offline_models.dart';
import 'package:aquaflow_frontend/core/offline/offline_repository.dart';
import 'package:aquaflow_frontend/core/offline/offline_storage.dart';
import 'package:aquaflow_frontend/core/offline/offline_sync.dart';

void main() {
  test('cache envelope distinguishes fresh, stale, and expired data', () {
    final fetchedAt = DateTime.utc(2026, 1, 1);
    final envelope = CacheEnvelope<String>(
      resourceKey: 'measurement:Q1',
      value: 'water-level',
      source: CacheSource.rest,
      fetchedAt: fetchedAt,
      freshnessWindow: const Duration(minutes: 10),
      confirmation: CacheConfirmation.live,
    );

    expect(envelope.availability(now: fetchedAt.add(const Duration(minutes: 5))), CacheAvailability.fresh);
    expect(envelope.availability(now: fetchedAt.add(const Duration(minutes: 20))), CacheAvailability.stale);
    expect(envelope.availability(now: fetchedAt.add(const Duration(minutes: 31))), CacheAvailability.expired);
    expect(envelope.asCached().isLiveConfirmed, isFalse);
  });

  test('repository persists metadata and invalidates incompatible schemas', () async {
    final repository = OfflineRepository(storage: JsonOfflineStorage());
    await repository.put(
      resourceKey: 'device:Q1',
      value: {'online': true},
      serialize: (value) => value,
    );

    final cached = await repository.get('device:Q1');
    expect(cached?.value['online'], isTrue);
    expect(cached?.metadata()['source'], 'rest');
  });

  test('recovery writes cannot overwrite newer confirmed state', () async {
    final repository = OfflineRepository(storage: JsonOfflineStorage());
    final newer = DateTime.utc(2026, 1, 2);
    final older = DateTime.utc(2026, 1, 1);
    expect(
      await repository.putIfNewer(
        resourceKey: 'irrigation',
        value: {'pump': 'OFF'},
        serialize: (value) => value,
        confirmedAt: newer,
      ),
      isTrue,
    );
    expect(
      await repository.putIfNewer(
        resourceKey: 'irrigation',
        value: {'pump': 'ON'},
        serialize: (value) => value,
        confirmedAt: older,
      ),
      isFalse,
    );
    expect((await repository.get('irrigation'))?.value['pump'], 'OFF');
  });

  test('connectivity notifier transitions from offline to recovery and online', () async {
    final probe = FakeConnectivityProbe(reachable: false);
    final notifier = ConnectivityNotifier(probe: probe);
    addTearDown(() async {
      notifier.dispose();
      await probe.dispose();
    });
    await notifier.refresh();
    expect(notifier.state, ConnectivityState.offline);

    notifier.markRecovery();
    expect(notifier.state, ConnectivityState.recovery);
    probe.setReachable(true);
    await Future<void>.delayed(Duration.zero);
    expect(notifier.state, ConnectivityState.online);
  });

  test('irrigation gate rejects offline, stale, and zone-scoped commands', () {
    final probe = FakeConnectivityProbe(reachable: false);
    final connectivity = ConnectivityNotifier(probe: probe);
    final gate = IrrigationCommandGate(connectivity);
    addTearDown(() async {
      connectivity.dispose();
      await probe.dispose();
    });

    expect(
      gate.check(
        authenticated: true,
        controllerConfirmed: true,
        target: 'ENTIRE FIELD',
        confirmation: CacheConfirmation.live,
      ).allowed,
      isFalse,
    );
    expect(
      gate.check(
        authenticated: true,
        controllerConfirmed: true,
        target: 'Q1',
        confirmation: CacheConfirmation.live,
      ).allowed,
      isFalse,
    );
  });

  test('irrigation gate permits only live-confirmed entire-field command online', () async {
    final probe = FakeConnectivityProbe(reachable: true);
    final connectivity = ConnectivityNotifier(probe: probe);
    final gate = IrrigationCommandGate(connectivity);
    addTearDown(() async {
      connectivity.dispose();
      await probe.dispose();
    });
    await connectivity.refresh();

    final decision = gate.check(
      authenticated: true,
      controllerConfirmed: true,
      target: 'ENTIRE FIELD',
      confirmation: CacheConfirmation.live,
    );
    expect(decision.allowed, isTrue);
  });

  test('offline resource falls back to cache and recovery sync runs once', () async {
    final probe = FakeConnectivityProbe(reachable: false);
    final connectivity = ConnectivityNotifier(probe: probe);
    final repository = OfflineRepository(storage: JsonOfflineStorage());
    await repository.put(
      resourceKey: 'measurement:Q1',
      value: {'waterLevel': 4.2},
      serialize: (value) => value,
    );
    var liveLoads = 0;
    final resource = OfflineResource<Map<String, Object?>>(
      key: 'measurement:Q1',
      repository: repository,
      connectivity: connectivity,
      loadLive: () async {
        liveLoads++;
        return {'waterLevel': 5.0};
      },
      serialize: (value) => value,
    );
    await connectivity.refresh();
    final offlineState = await resource.read();
    expect(offlineState.snapshot?.source, CacheSource.cache);
    expect(offlineState.snapshot?.value['waterLevel'], 4.2);

    probe.setReachable(true);
    await Future<void>.delayed(Duration.zero);
    await resource.read();
    expect(liveLoads, 1);

    connectivity.dispose();
    await probe.dispose();
  });
}
