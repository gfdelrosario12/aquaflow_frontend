import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/aqua_button.dart';
import '../../../core/widgets/aqua_card.dart';
import '../../../core/widgets/aqua_chart_container.dart';
import '../../../core/widgets/aqua_chip_selector.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/loading_state_widget.dart';
import '../../../core/widgets/responsive_container.dart';
import '../../../core/widgets/sensor_metric_tile.dart';
import '../../../core/widgets/simulated_telemetry_chart.dart';
import '../../../core/widgets/status_badge.dart';
import '../../control/presentation/control_screen.dart';
import '../data/datasources/zone_data_source.dart';
import '../data/repositories/zone_repository.dart';
import '../domain/models/monitoring_zone.dart';

enum TimeframeFilter { tf24h, tf7d }

class ZoneAnalysisScreen extends StatefulWidget {
  final String zoneCode;
  final MonitoringZone? initialZone;
  final ZoneRepository? repository;
  final ZoneMockState mockState;

  const ZoneAnalysisScreen({
    super.key,
    required this.zoneCode,
    this.initialZone,
    this.repository,
    this.mockState = ZoneMockState.normal,
  });

  @override
  State<ZoneAnalysisScreen> createState() => _ZoneAnalysisScreenState();
}

class _ZoneAnalysisScreenState extends State<ZoneAnalysisScreen> {
  late final ZoneRepository _repository;
  MonitoringZone? _zone;
  bool _isLoading = true;
  String? _errorMessage;
  TimeframeFilter _selectedTimeframe = TimeframeFilter.tf24h;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? ZoneRepositoryImpl();
    if (widget.initialZone != null) {
      _zone = widget.initialZone;
      _isLoading = false;
    } else {
      _loadZoneDetails();
    }
  }

  Future<void> _loadZoneDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final zone = await _repository.fetchZoneDetails(
        widget.zoneCode,
        mockState: widget.mockState,
      );
      if (mounted) {
        setState(() {
          _zone = zone;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.zoneCode} Detailed Analysis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadZoneDetails,
            tooltip: 'Refresh Telemetry',
          ),
        ],
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return const LoadingStateWidget(
        message: 'Fetching quadrant telemetry & history...',
      );
    }

    if (_errorMessage != null) {
      return ErrorStateWidget(
        title: 'Telemetry Gateway Error',
        message: _errorMessage!,
        onRetry: _loadZoneDetails,
      );
    }

    if (_zone == null) {
      return EmptyStateWidget(
        title: 'Quadrant Not Found',
        message: 'No monitoring data available for zone ${widget.zoneCode}.',
        onAction: _loadZoneDetails,
        actionLabel: 'Reload Telemetry',
      );
    }

    final zone = _zone!;
    final history = _selectedTimeframe == TimeframeFilter.tf24h
        ? zone.waterLevelHistory24h
        : zone.waterLevelHistory7d;
    final trend = zone.trendAnalysisFor(history);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spaceMd),
      child: ResponsiveContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Zone Overview Header Card
            _buildHeaderCard(theme, zone),
            const SizedBox(height: AppDimensions.spaceMd),

            // Read-Only AWD & Centralized Irrigation Redirection Banner
            _buildRedirectionBanner(theme, zone),
            const SizedBox(height: AppDimensions.spaceMd),

            // Trend Analysis Summary Card
            _buildTrendSummaryCard(theme, trend),
            const SizedBox(height: AppDimensions.spaceMd),

            // Real-Time Sensor Metrics Grid
            _buildMetricsGrid(theme, zone),
            const SizedBox(height: AppDimensions.spaceMd),

            // Historical Telemetry Chart with Timeframe Selector
            _buildHistoricalChartSection(theme, zone, history),
            const SizedBox(height: AppDimensions.spaceMd),

            // LoRaWAN Hardware & Sensor Diagnostic Panel
            _buildDiagnosticPanel(theme, zone),
            const SizedBox(height: AppDimensions.spaceLg),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(ThemeData theme, MonitoringZone zone) {
    return AquaCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      zone.code,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spaceSm),
                    StatusBadge.zoneStatus(zone.status.name),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  zone.name,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          StatusBadge.deviceStatus(zone.isOnline ? 'Online' : 'Offline'),
        ],
      ),
    );
  }

  Widget _buildRedirectionBanner(ThemeData theme, MonitoringZone zone) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
              const SizedBox(width: AppDimensions.spaceSm),
              Expanded(
                child: Text(
                  'Read-Only Telemetry Station (${zone.code})',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceSm),
          Text(
            'Monitoring zones Q1–Q4 serve as read-only telemetry points. Zone-level pump or valve activation controls are not available because centralized irrigation serves the entire field as a single operational unit.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppDimensions.spaceSm),
          AquaButton(
            label: 'Go to Centralized Controls',
            icon: Icons.settings_remote,
            variant: AquaButtonVariant.outline,
            isFullWidth: false,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ControlScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTrendSummaryCard(ThemeData theme, ZoneTrendAnalysis trend) {
    Color badgeColor;
    IconData trendIcon;
    String trendDescription;

    switch (trend.direction) {
      case TrendDirection.wetter:
        badgeColor = AppColors.info;
        trendIcon = Icons.trending_up;
        trendDescription =
            'Water level is increasing over the selected time window. The soil profile is absorbing or retaining water.';
        break;
      case TrendDirection.drier:
        badgeColor = AppColors.warning;
        trendIcon = Icons.trending_down;
        trendDescription =
            'Water level is dropping over the selected time window. Drainage or crop evapotranspiration is depleting moisture.';
        break;
      case TrendDirection.stable:
        badgeColor = AppColors.primary;
        trendIcon = Icons.trending_flat;
        trendDescription =
            'Water level is stable with minimal fluctuation over the selected time window.';
        break;
    }

    return AquaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Water Condition Trend Analysis',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.spaceSm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spaceSm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(trendIcon, size: 16, color: badgeColor),
                    const SizedBox(width: 4),
                    Text(
                      trend.label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: badgeColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceSm),
          Text(
            trendDescription,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(ThemeData theme, MonitoringZone zone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current Telemetry Readings',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.spaceSm),
        Row(
          children: [
            Expanded(
              child: SensorMetricTile(
                label: 'Soil Moisture',
                value: '${zone.soilMoisturePercent.toStringAsFixed(1)}%',
                icon: Icons.water_drop,
                color: AppColors.primary,
              ),
            ),
            Expanded(
              child: SensorMetricTile(
                label: 'Water Depth',
                value: '${zone.waterLevelCm} cm',
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
                label: 'Temperature',
                value: '${zone.temperatureCelsius.toStringAsFixed(1)}°C',
                icon: Icons.thermostat,
                color: AppColors.primaryLight,
              ),
            ),
            Expanded(
              child: SensorMetricTile(
                label: 'Humidity',
                value: '${zone.humidityPercent.toStringAsFixed(1)}%',
                icon: Icons.cloud,
                color: AppColors.primaryDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHistoricalChartSection(
    ThemeData theme,
    MonitoringZone zone,
    List<double> history,
  ) {
    final timeframeLabel =
        _selectedTimeframe == TimeframeFilter.tf24h ? '24-Hour' : '7-Day';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Historical Water Level',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.spaceSm),
        AquaChipSelector<TimeframeFilter>(
          options: const [
            AquaChipOption(value: TimeframeFilter.tf24h, label: '24h Trend'),
            AquaChipOption(value: TimeframeFilter.tf7d, label: '7d History'),
          ],
          selectedValue: _selectedTimeframe,
          onSelected: (tf) {
            setState(() {
              _selectedTimeframe = tf;
            });
          },
        ),
        const SizedBox(height: AppDimensions.spaceSm),
        AquaChartContainer(
          title: '${zone.code} Water Depth ($timeframeLabel)',
          subtitle:
              'Water depth readings over ${_selectedTimeframe == TimeframeFilter.tf24h ? 'hourly interval' : '7-day daily average'}',
          chartWidget: SimulatedTelemetryChart(
            dataPoints: history,
            labelSuffix: 'cm',
            lineColor: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildDiagnosticPanel(ThemeData theme, MonitoringZone zone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sensor Node Hardware Diagnostics',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.spaceSm),
        AquaCard(
          padding: const EdgeInsets.all(AppDimensions.spaceSm),
          child: Column(
            children: [
              _buildDiagnosticRow(
                theme,
                label: 'Uplink Status',
                value: zone.isOnline ? 'ONLINE (LoRaWAN)' : 'OFFLINE',
                valueColor: zone.isOnline ? AppColors.success : AppColors.error,
                icon: zone.isOnline ? Icons.sensors : Icons.sensors_off,
              ),
              const Divider(height: 12),
              _buildDiagnosticRow(
                theme,
                label: 'Signal Strength (RSSI)',
                value: '${zone.rssiDbm} dBm',
                icon: Icons.cell_tower,
              ),
              const Divider(height: 12),
              _buildDiagnosticRow(
                theme,
                label: 'Signal-to-Noise Ratio (SNR)',
                value: '${zone.snrDb} dB',
                icon: Icons.graphic_eq,
              ),
              const Divider(height: 12),
              _buildDiagnosticRow(
                theme,
                label: 'Battery Health',
                value: '${zone.batteryPercent}%',
                valueColor: zone.batteryPercent < 20 ? AppColors.error : null,
                icon: zone.batteryPercent < 20
                    ? Icons.battery_alert
                    : Icons.battery_full,
              ),
              const Divider(height: 12),
              _buildDiagnosticRow(
                theme,
                label: 'Hardware Model',
                value: zone.hardwareModel,
                icon: Icons.memory,
              ),
              const Divider(height: 12),
              _buildDiagnosticRow(
                theme,
                label: 'Firmware Version',
                value: zone.firmwareVersion,
                icon: Icons.developer_board,
              ),
              const Divider(height: 12),
              _buildDiagnosticRow(
                theme,
                label: 'Last Sensor Ping',
                value: _formatFullTime(zone.lastUpdated),
                icon: Icons.access_time,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDiagnosticRow(
    ThemeData theme, {
    required String label,
    required String value,
    Color? valueColor,
    required IconData icon,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: AppDimensions.spaceSm),
              Flexible(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppDimensions.spaceSm),
        Flexible(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatFullTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
