import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/aqua_card.dart';
import '../../../../core/widgets/sensor_metric_tile.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../irrigation/domain/models/centralized_irrigation.dart';

class CentralIrrigationOverviewCard extends StatelessWidget {
  final CentralizedIrrigation system;

  CentralIrrigationOverviewCard({
    super.key,
    required this.system,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPumpActive = system.mainPumpState == PumpState.active;

    return AquaCard(
      gradient: LinearGradient(
        colors: isPumpActive
            ? [
                theme.cardTheme.color ?? theme.colorScheme.surface,
                const Color(0xFF0F3A40),
              ]
            : [
                theme.cardTheme.color ?? theme.colorScheme.surface,
                theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.water_drop,
                      color: isPumpActive ? AppColors.pumpActive : AppColors.primary,
                    ),
                    const SizedBox(width: AppDimensions.spaceSm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Autonomous Edge Irrigation',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Edge Node-Driven Automated Execution',
                            style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge.irrigationStatus(isPumpActive, compact: true),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceMd),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: SensorMetricTile(
                  label: 'Flow Rate',
                  value: system.flowRateLitersPerMin.toStringAsFixed(1),
                  unit: 'L/m',
                  icon: Icons.speed,
                  color: AppColors.primary,
                ),
              ),
              Expanded(
                child: SensorMetricTile(
                  label: 'Pressure',
                  value: system.pressureBar.toStringAsFixed(1),
                  unit: 'bar',
                  icon: Icons.compress,
                  color: AppColors.accent,
                ),
              ),
              Expanded(
                child: SensorMetricTile(
                  label: 'Main Valve',
                  value: system.distributionValveState.name.toUpperCase(),
                  unit: 'State',
                  icon: Icons.alt_route,
                  color: AppColors.primaryLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

