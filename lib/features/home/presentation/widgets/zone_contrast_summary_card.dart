import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/aqua_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../zones/domain/models/monitoring_zone.dart';
import '../../../zones/presentation/zone_analysis_screen.dart';
import '../../domain/models/field_dashboard_summary.dart';

class ZoneContrastSummaryCard extends StatelessWidget {
  final FieldDashboardSummary summary;
  final VoidCallback? onNavigateToField;

  const ZoneContrastSummaryCard({
    super.key,
    required this.summary,
    this.onNavigateToField,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final zones = summary.monitoringZones;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Monitoring Zones Breakdown (Q1–Q4)',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (onNavigateToField != null)
              TextButton(
                onPressed: onNavigateToField,
                child: const Text('Field Details'),
              ),
          ],
        ),
        if (summary.wetterZoneCode != null || summary.drierZoneCode != null) ...[
          const SizedBox(height: AppDimensions.spaceXs),
          Container(
            padding: const EdgeInsets.all(AppDimensions.spaceSm),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.compare_arrows,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppDimensions.spaceSm),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: theme.textTheme.bodySmall,
                      children: [
                        const TextSpan(text: 'Moisture Contrast: '),
                        if (summary.wetterZoneCode != null) ...[
                          TextSpan(
                            text: '${summary.wetterZoneCode} is Wetter ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                        if (summary.drierZoneCode != null) ...[
                          const TextSpan(text: '| '),
                          TextSpan(
                            text: '${summary.drierZoneCode} is Drier',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppDimensions.spaceSm),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppDimensions.spaceSm,
            mainAxisSpacing: AppDimensions.spaceSm,
            childAspectRatio: 1.25,
          ),
          itemCount: zones.length,
          itemBuilder: (context, index) {
            final zone = zones[index];
            final isWetter = zone.code == summary.wetterZoneCode;
            final isDrier = zone.code == summary.drierZoneCode;
            return _buildZoneItem(context, zone, isWetter, isDrier);
          },
        ),
      ],
    );
  }

  Widget _buildZoneItem(
    BuildContext context,
    MonitoringZone zone,
    bool isWetter,
    bool isDrier,
  ) {
    final theme = Theme.of(context);

    Color borderHighlight = Colors.transparent;
    if (isWetter) borderHighlight = AppColors.success;
    if (isDrier) borderHighlight = AppColors.warning;

    return AquaCard(
      borderColor: borderHighlight != Colors.transparent ? borderHighlight : null,
      padding: const EdgeInsets.all(AppDimensions.spaceSm),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ZoneAnalysisScreen(
              zoneCode: zone.code,
              initialZone: zone,
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                zone.code,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isWetter)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'WETTER',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                )
              else if (isDrier)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'DRIER',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.warning,
                    ),
                  ),
                )
              else
                StatusBadge.zoneStatus(zone.status.name, compact: true),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Soil Moisture',
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
              ),
              Text(
                '${zone.soilMoisturePercent.toStringAsFixed(1)}%',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Water: ${zone.waterLevelCm}cm',
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
              ),
              const Icon(
                Icons.sensors,
                size: 13,
                color: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
