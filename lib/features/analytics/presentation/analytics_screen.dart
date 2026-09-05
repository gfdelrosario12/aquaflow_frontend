import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/widgets.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ResponsiveContainer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Field Analytics',
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Historical telemetry & AWD moisture trends',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
                StatusBadge.awdStatus('Safe Level'),
              ],
            ),
            const SizedBox(height: AppDimensions.spaceMd),
            _buildStatCardsRow(context),
            const SizedBox(height: AppDimensions.spaceLg),
            AquaChartContainer(
              title: '24-Hour Soil Moisture Trend (Q1–Q4)',
              subtitle: 'Average volumetric moisture percentage across field',
              trailingHeader: StatusBadge.zoneStatus('Optimal', compact: true),
              chartWidget: const SimulatedTelemetryChart(
                dataPoints: [28.0, 32.5, 30.0, 36.4, 34.1, 38.0, 35.5],
                lineColor: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceMd),
            AquaChartContainer(
              title: 'Central Field Water Consumption',
              subtitle: 'Daily volume supplied by central irrigation pump',
              chartWidget: const SimulatedTelemetryChart(
                dataPoints: [1100, 1400, 1250, 1600, 1450, 1300, 1500],
                lineColor: AppColors.accent,
                labelSuffix: 'L',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCardsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AquaCard(
            padding: const EdgeInsets.all(AppDimensions.spaceSm),
            child: SensorMetricTile(
              label: 'Avg Moisture',
              value: '34.1%',
              icon: Icons.water_drop,
              color: AppColors.primary,
              subtitle: 'Target: 30%-40%',
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.spaceSm),
        Expanded(
          child: AquaCard(
            padding: const EdgeInsets.all(AppDimensions.spaceSm),
            child: SensorMetricTile(
              label: 'Daily Usage',
              value: '1,450',
              unit: 'L',
              icon: Icons.opacity,
              color: AppColors.accent,
              subtitle: 'Optimal AWD',
            ),
          ),
        ),
      ],
    );
  }
}
