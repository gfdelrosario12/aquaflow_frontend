import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/aqua_button.dart';
import '../../../../core/widgets/aqua_card.dart';
import '../../../../core/widgets/aqua_chart_container.dart';
import '../../../../core/widgets/sensor_metric_tile.dart';
import '../../../../core/widgets/simulated_telemetry_chart.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../zones/domain/models/monitoring_zone.dart';
import '../../../zones/presentation/zone_analysis_screen.dart';

class ZoneDetailBottomSheet extends StatelessWidget {
  final MonitoringZone zone;
  final VoidCallback? onNavigateToControl;

  const ZoneDetailBottomSheet({
    super.key,
    required this.zone,
    this.onNavigateToControl,
  });

  static void show(
    BuildContext context, {
    required MonitoringZone zone,
    VoidCallback? onNavigateToControl,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ZoneDetailBottomSheet(
        zone: zone,
        onNavigateToControl: onNavigateToControl,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLg),
        ),
      ),
      padding: EdgeInsets.only(
        left: AppDimensions.spaceMd,
        right: AppDimensions.spaceMd,
        top: AppDimensions.spaceMd,
        bottom: MediaQuery.of(context).padding.bottom + AppDimensions.spaceMd,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spaceMd),
            Row(
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
                          StatusBadge.zoneStatus(zone.status.name, compact: true),
                        ],
                      ),
                      Text(
                        zone.name,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                StatusBadge.deviceStatus(
                  zone.isOnline ? 'Online' : 'Offline',
                  compact: true,
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spaceMd),

            // Metrics overview
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
                Expanded(
                  child: SensorMetricTile(
                    label: 'Temperature',
                    value: '${zone.temperatureCelsius.toStringAsFixed(1)}°C',
                    icon: Icons.thermostat,
                    color: AppColors.primaryLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spaceMd),

            // LoRaWAN & Hardware Diagnostics
            Text(
              'Sensor Diagnostics & Network Info',
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
                    context,
                    label: 'Connection State',
                    value: zone.isOnline ? 'ONLINE' : 'OFFLINE',
                    valueColor: zone.isOnline ? AppColors.success : AppColors.error,
                    icon: zone.isOnline ? Icons.sensors : Icons.sensors_off,
                  ),
                  const Divider(height: 12),
                  _buildDiagnosticRow(
                    context,
                    label: 'Signal Strength (RSSI)',
                    value: '${zone.rssiDbm} dBm',
                    icon: Icons.cell_tower,
                  ),
                  const Divider(height: 12),
                  _buildDiagnosticRow(
                    context,
                    label: 'Signal Quality (SNR)',
                    value: '${zone.snrDb} dB',
                    icon: Icons.graphic_eq,
                  ),
                  const Divider(height: 12),
                  _buildDiagnosticRow(
                    context,
                    label: 'Battery Status',
                    value: '${zone.batteryPercent}%',
                    valueColor: zone.batteryPercent < 20 ? AppColors.error : null,
                    icon: zone.batteryPercent < 20 ? Icons.battery_alert : Icons.battery_full,
                  ),
                  const Divider(height: 12),
                  _buildDiagnosticRow(
                    context,
                    label: 'Hardware / Firmware',
                    value: '${zone.hardwareModel} (${zone.firmwareVersion})',
                    icon: Icons.developer_board,
                  ),
                  const Divider(height: 12),
                  _buildDiagnosticRow(
                    context,
                    label: 'Last Telemetry Update',
                    value: _formatFullTime(zone.lastUpdated),
                    icon: Icons.access_time,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spaceMd),

            // Water depth trend chart
            AquaChartContainer(
              title: 'Water Level History (${zone.code})',
              subtitle: 'Recent 5-point sensor telemetry readings (cm)',
              chartWidget: SimulatedTelemetryChart(
                dataPoints: zone.waterLevelHistory,
                labelSuffix: 'cm',
                lineColor: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceMd),
            AquaButton(
              label: 'View Detailed Zone Analysis (${zone.code})',
              icon: Icons.analytics_outlined,
              isFullWidth: true,
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ZoneAnalysisScreen(
                      zoneCode: zone.code,
                      initialZone: zone,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppDimensions.spaceLg),

            // Read-Only Warning Banner & Centralized Irrigation Note
            Container(
              padding: const EdgeInsets.all(AppDimensions.spaceSm),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, size: 18, color: AppColors.primary),
                      const SizedBox(width: AppDimensions.spaceSm),
                      Expanded(
                        child: Text(
                          'Read-Only Monitoring Point (${zone.code})',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Monitoring zones do not contain individual pump or valve controls. Centralized irrigation serves the entire field as a single operational unit.',
                    style: theme.textTheme.bodySmall,
                  ),
                  if (onNavigateToControl != null) ...[
                    const SizedBox(height: AppDimensions.spaceSm),
                    AquaButton(
                      label: 'Go to Centralized Controls',
                      icon: Icons.settings_remote,
                      variant: AquaButtonVariant.outline,
                      isFullWidth: false,
                      onPressed: () {
                        Navigator.of(context).pop();
                        onNavigateToControl?.call();
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagnosticRow(
    BuildContext context, {
    required String label,
    required String value,
    Color? valueColor,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
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
