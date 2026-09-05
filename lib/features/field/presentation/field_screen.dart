import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/widgets.dart';
import '../../zones/data/datasources/zone_data_source.dart';
import '../../zones/data/repositories/zone_repository.dart';
import '../../zones/domain/models/monitoring_zone.dart';
import 'widgets/field_header_overview_card.dart';
import 'widgets/quadrant_grid_visualizer.dart';
import 'widgets/zone_detail_bottom_sheet.dart';

class FieldScreen extends StatefulWidget {
  final VoidCallback? onNavigateToControl;
  final ZoneRepository? repository;

  const FieldScreen({
    super.key,
    this.onNavigateToControl,
    this.repository,
  });

  @override
  State<FieldScreen> createState() => _FieldScreenState();
}

class _FieldScreenState extends State<FieldScreen> {
  late final ZoneRepository _zoneRepository;

  bool _isLoading = true;
  String? _errorMessage;
  List<MonitoringZone> _zones = [];
  ZoneMockState _currentMockState = ZoneMockState.normal;
  String? _selectedZoneCode;

  @override
  void initState() {
    super.initState();
    _zoneRepository = widget.repository ?? ZoneRepositoryImpl();
    _loadZones();
  }

  Future<void> _loadZones({ZoneMockState? overrideState}) async {
    final stateToFetch = overrideState ?? _currentMockState;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentMockState = stateToFetch;
    });

    try {
      final zones = await _zoneRepository.fetchMonitoringZones(
        mockState: stateToFetch,
      );
      if (mounted) {
        setState(() {
          _zones = zones;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  void _handleZoneSelection(MonitoringZone zone) {
    setState(() => _selectedZoneCode = zone.code);
    ZoneDetailBottomSheet.show(
      context,
      zone: zone,
      onNavigateToControl: widget.onNavigateToControl,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ResponsiveContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: _buildBody(theme),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return const LoadingStateWidget(
        message: 'Loading Field Zone Telemetry...',
      );
    }

    if (_errorMessage != null) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spaceMd),
            child: _buildHeader(theme),
          ),
          Expanded(
            child: ErrorStateWidget(
              title: 'Gateway Telemetry Error',
              message: _errorMessage!,
              onRetry: () => _loadZones(overrideState: ZoneMockState.normal),
            ),
          ),
        ],
      );
    }

    if (_zones.isEmpty) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spaceMd),
            child: _buildHeader(theme),
          ),
          Expanded(
            child: EmptyStateWidget(
              title: 'No Monitoring Quadrants',
              message: 'No sensor nodes deployed or active in this field.',
              actionLabel: 'Reset Telemetry',
              onAction: () => _loadZones(overrideState: ZoneMockState.normal),
            ),
          ),
        ],
      );
    }

    final isStale = _currentMockState == ZoneMockState.stale;

    return RefreshIndicator(
      onRefresh: () => _loadZones(),
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppDimensions.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme),
            const SizedBox(height: AppDimensions.spaceMd),
            FieldHeaderOverviewCard(
              zones: _zones,
              isStale: isStale,
            ),
            const SizedBox(height: AppDimensions.spaceLg),
            QuadrantGridVisualizer(
              zones: _zones,
              selectedZoneCode: _selectedZoneCode,
              onZoneSelected: _handleZoneSelection,
            ),
            const SizedBox(height: AppDimensions.spaceLg),
            Text(
              'Detailed Quadrant Telemetry List',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceSm),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _zones.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppDimensions.spaceMd),
              itemBuilder: (context, index) {
                return _buildZoneCard(_zones[index]);
              },
            ),
            const SizedBox(height: AppDimensions.spaceLg),
            _buildMonitoringNoticeCard(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AquaSense Field Monitoring',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                'Independent Telemetry Quadrants Q1–Q4',
                style: theme.textTheme.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        PopupMenuButton<ZoneMockState>(
          icon: const Icon(Icons.tune, color: AppColors.primary),
          tooltip: 'Simulate UI States',
          onSelected: (ZoneMockState state) => _loadZones(overrideState: state),
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem(
              value: ZoneMockState.normal,
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline, size: 18, color: AppColors.success),
                  SizedBox(width: 8),
                  Text('Normal State'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: ZoneMockState.stale,
              child: Row(
                children: [
                  Icon(Icons.history, size: 18, color: AppColors.warning),
                  SizedBox(width: 8),
                  Text('Stale Telemetry'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: ZoneMockState.unavailable,
              child: Row(
                children: [
                  Icon(Icons.sensors_off, size: 18, color: AppColors.error),
                  SizedBox(width: 8),
                  Text('Gateway Offline'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: ZoneMockState.empty,
              child: Row(
                children: [
                  Icon(Icons.inbox, size: 18, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text('Empty State'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: ZoneMockState.error,
              child: Row(
                children: [
                  Icon(Icons.error_outline, size: 18, color: AppColors.error),
                  SizedBox(width: 8),
                  Text('Error State'),
                ],
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: () => _loadZones(),
          icon: const Icon(Icons.sync, color: AppColors.primary),
          tooltip: 'Sync Field Data',
        ),
      ],
    );
  }

  Widget _buildMonitoringNoticeCard(ThemeData theme) {
    return AquaCard(
      child: Row(
        children: [
          const Icon(Icons.shield_outlined, color: AppColors.primary, size: 24),
          const SizedBox(width: AppDimensions.spaceSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monitoring Quadrants Only',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Q1–Q4 display environmental & soil telemetry. Physical irrigation control is managed centrally under the Control tab.',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneCard(MonitoringZone zone) {
    return AquaCard(
      onTap: () => _handleZoneSelection(zone),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spaceSm,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: Text(
                        zone.code,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spaceSm),
                    Expanded(
                      child: Text(
                        zone.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.spaceSm),
              StatusBadge.zoneStatus(zone.status.name, compact: true),
            ],
          ),
          const Divider(height: 20),
          Row(
            children: [
              Expanded(
                child: SensorMetricTile(
                  label: 'Soil Moisture',
                  value: '${zone.soilMoisturePercent.toStringAsFixed(1)}%',
                  icon: Icons.water,
                  color: AppColors.primary,
                ),
              ),
              Expanded(
                child: SensorMetricTile(
                  label: 'Water Level',
                  value: zone.waterLevelCm.toStringAsFixed(1),
                  unit: 'cm',
                  icon: Icons.waves,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceSm),
          Row(
            children: [
              Expanded(
                child: SensorMetricTile(
                  label: 'Signal (RSSI)',
                  value: '${zone.rssiDbm}',
                  unit: 'dBm',
                  icon: Icons.cell_tower,
                  color: AppColors.primaryLight,
                ),
              ),
              Expanded(
                child: SensorMetricTile(
                  label: 'Sensor Battery',
                  value: zone.batteryPercent.toString(),
                  unit: '%',
                  icon: zone.batteryPercent < 20
                      ? Icons.battery_alert
                      : Icons.battery_full,
                  color: zone.batteryPercent < 20
                      ? AppColors.error
                      : AppColors.deviceBatteryGood,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
