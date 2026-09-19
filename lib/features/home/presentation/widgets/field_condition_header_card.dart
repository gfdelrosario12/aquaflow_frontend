import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/aqua_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../awd/domain/models/awd_automation_eligibility.dart';
import '../../../awd/domain/models/awd_confidence.dart';
import '../../domain/models/field_dashboard_summary.dart';

class FieldConditionHeaderCard extends StatelessWidget {
  final FieldDashboardSummary summary;

  const FieldConditionHeaderCard({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final conditionColor = _getConditionColor(summary.overallCondition);

    return AquaCard(
      gradient: LinearGradient(
        colors: [
          conditionColor.withValues(alpha: isDark ? 0.25 : 0.12),
          theme.cardTheme.color ?? theme.colorScheme.surface,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (summary.isStale) ...[
            Container(
              margin: const EdgeInsets.only(bottom: AppDimensions.spaceSm),
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spaceSm,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                border: Border.all(color: AppColors.warning),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.history,
                    size: 14,
                    color: AppColors.warning,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'STALE TELEMETRY DATA (>15m)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overall Field Condition',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      summary.overallConditionLabel,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: conditionColor,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StatusBadge.awdStatus(summary.awdStatusLabel, compact: true),
                  if (summary.confidence != null) ...[
                    const SizedBox(height: 4),
                    _buildConfidenceChip(theme, summary.confidence!),
                  ],
                  if (summary.autoEligibility != null) ...[
                    const SizedBox(height: 4),
                    _buildAutoEligibilityChip(theme, summary.autoEligibility!),
                  ],
                ],
              ),
            ],
          ),
          if (summary.requiresIrrigation &&
              summary.autoEligibility != null &&
              !summary.autoEligibility!.isEligibleForAutoIrrigation &&
              summary.autoEligibility!.inhibitionReasons.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spaceSm),
            _buildAutoInhibitionBanner(theme, summary.autoEligibility!),
          ],
          const SizedBox(height: AppDimensions.spaceMd),
          Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 14,
                color: AppColors.primary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Synced: ${_formatTime(summary.lastUpdated)}',
                  style: theme.textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.radar,
                size: 14,
                color: AppColors.primary,
              ),
              const SizedBox(width: 4),
              Text(
                summary.monitoringZones.isNotEmpty
                    ? (summary.monitoringZones.where((z) => z.isOnline).length == summary.monitoringZones.length
                        ? '${summary.monitoringZones.length} Zones Active'
                        : '${summary.monitoringZones.where((z) => z.isOnline).length}/${summary.monitoringZones.length} Zones Active')
                    : 'No Zones Active',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getConditionColor(FieldConditionStatus status) {
    switch (status) {
      case FieldConditionStatus.optimal:
        return AppColors.success;
      case FieldConditionStatus.refluxNeeded:
        return AppColors.warning;
      case FieldConditionStatus.flooded:
        return AppColors.accent;
      case FieldConditionStatus.criticallyDry:
        return AppColors.error;
    }
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Widget _buildConfidenceChip(ThemeData theme, AwdConfidence confidence) {
    final Color color;
    final IconData icon;
    switch (confidence.level) {
      case AwdConfidenceLevel.high:
        color = AppColors.success;
        icon = Icons.verified;
        break;
      case AwdConfidenceLevel.medium:
        color = AppColors.primary;
        icon = Icons.info_outline;
        break;
      case AwdConfidenceLevel.low:
        color = AppColors.warning;
        icon = Icons.warning_amber_outlined;
        break;
      case AwdConfidenceLevel.insufficient:
        color = AppColors.error;
        icon = Icons.error_outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            '${confidence.level.label} (${(confidence.score * 100).round()}%)',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAutoEligibilityChip(
      ThemeData theme, AwdAutomationEligibility eligibility) {
    final isEligible = eligibility.isEligibleForAutoIrrigation;
    final color = isEligible ? AppColors.success : AppColors.alertWarning;
    final icon = isEligible ? Icons.auto_mode : Icons.lock_outline;
    final label = isEligible
        ? 'Auto: ${eligibility.recommendedDurationMinutes}m'
        : 'Auto: Inhibited';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAutoInhibitionBanner(
      ThemeData theme, AwdAutomationEligibility eligibility) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.alertWarning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        border: Border.all(color: AppColors.alertWarning.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield_outlined, size: 14, color: AppColors.alertWarning),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Auto-Irrigation Inhibited: ${eligibility.inhibitionReasons.map(AwdInhibitionReason.toHumanDescription).join('; ')}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.alertWarning,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
