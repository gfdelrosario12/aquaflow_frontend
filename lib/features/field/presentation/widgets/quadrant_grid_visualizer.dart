import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/aqua_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../zones/domain/models/monitoring_zone.dart';

class QuadrantGridVisualizer extends StatelessWidget {
  final List<MonitoringZone> zones;
  final ValueChanged<MonitoringZone>? onZoneSelected;
  final String? selectedZoneCode;

  const QuadrantGridVisualizer({
    super.key,
    required this.zones,
    this.onZoneSelected,
    this.selectedZoneCode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Monitoring Quadrants Matrix (Q1–Q4)',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Icon(
              Icons.touch_app,
              size: 16,
              color: AppColors.primary,
            ),
            const SizedBox(width: 4),
            Text(
              'Tap zone for details',
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spaceSm),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppDimensions.spaceSm,
            mainAxisSpacing: AppDimensions.spaceSm,
            childAspectRatio: 1.15,
          ),
          itemCount: zones.length,
          itemBuilder: (context, index) {
            final zone = zones[index];
            final isSelected = zone.code == selectedZoneCode;
            return _buildZoneCard(context, zone, isSelected);
          },
        ),
      ],
    );
  }

  Widget _buildZoneCard(
    BuildContext context,
    MonitoringZone zone,
    bool isSelected,
  ) {
    final theme = Theme.of(context);
    final isOnline = zone.isOnline;

    Color borderHighlight = Colors.transparent;
    if (isSelected) {
      borderHighlight = AppColors.primary;
    } else if (zone.status == ZoneStatus.critical) {
      borderHighlight = AppColors.error;
    } else if (zone.status == ZoneStatus.warning) {
      borderHighlight = AppColors.warning;
    }

    return AquaCard(
      borderColor: borderHighlight != Colors.transparent ? borderHighlight : null,
      padding: const EdgeInsets.all(AppDimensions.spaceSm),
      onTap: () => onZoneSelected?.call(zone),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    zone.code,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: isOnline ? AppColors.success : AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
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
              Expanded(
                child: Text(
                  'Water: ${zone.waterLevelCm}cm',
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: [
                  Icon(
                    _getBatteryIcon(zone.batteryPercent),
                    size: 13,
                    color: zone.batteryPercent < 20 ? AppColors.error : AppColors.primary,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${zone.batteryPercent}%',
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getBatteryIcon(int percent) {
    if (percent > 80) return Icons.battery_full;
    if (percent > 50) return Icons.battery_5_bar;
    if (percent > 20) return Icons.battery_2_bar;
    return Icons.battery_alert;
  }
}

