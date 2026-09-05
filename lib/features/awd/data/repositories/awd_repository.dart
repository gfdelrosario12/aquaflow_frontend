import '../../../zones/data/datasources/zone_data_source.dart';
import '../../../zones/data/repositories/zone_repository.dart';
import '../../domain/models/awd_analytics_summary.dart';
import '../../domain/models/awd_threshold_config.dart';
import '../../domain/services/awd_rule_engine.dart';

enum AwdMockState { normal, insufficientData, stale, unavailable, error }

abstract class AwdRepository {
  Future<AwdAnalyticsSummary> fetchAwdAnalytics({
    AwdThresholdConfig config = const AwdThresholdConfig(),
    AwdMockState mockState = AwdMockState.normal,
  });
}

class AwdRepositoryImpl implements AwdRepository {
  final ZoneRepository _zoneRepository;

  AwdRepositoryImpl({ZoneRepository? zoneRepository})
      : _zoneRepository = zoneRepository ?? ZoneRepositoryImpl();

  @override
  Future<AwdAnalyticsSummary> fetchAwdAnalytics({
    AwdThresholdConfig config = const AwdThresholdConfig(),
    AwdMockState mockState = AwdMockState.normal,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));

    if (mockState == AwdMockState.error) {
      throw Exception(
        'AWD Analytics Engine Error: Unable to process field telemetry uplink.',
      );
    }

    if (mockState == AwdMockState.unavailable) {
      throw Exception(
        'Gateway Telemetry Unavailable: Telemetry gateway (GW-01) offline.',
      );
    }

    // Map AwdMockState to ZoneMockState
    ZoneMockState zoneMockState = ZoneMockState.normal;
    if (mockState == AwdMockState.stale) {
      zoneMockState = ZoneMockState.stale;
    }

    final zones = await _zoneRepository.fetchMonitoringZones(
      mockState: zoneMockState,
    );

    if (mockState == AwdMockState.insufficientData) {
      // Simulate only 2 zones returning telemetry
      final subsetZones = zones.take(2).toList();
      return AwdRuleEngine.evaluateFieldAwd(
        zones: subsetZones,
        config: config,
        isStaleData: false,
      );
    }

    return AwdRuleEngine.evaluateFieldAwd(
      zones: zones,
      config: config,
      isStaleData: mockState == AwdMockState.stale,
    );
  }
}

