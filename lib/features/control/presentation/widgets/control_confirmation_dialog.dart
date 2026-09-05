import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../domain/models/models.dart';

class ControlConfirmationDialog extends StatefulWidget {
  final CommandType commandType;
  final ControlUserRole userRole;

  const ControlConfirmationDialog({
    super.key,
    required this.commandType,
    this.userRole = ControlUserRole.operator,
  });

  static Future<ControlConfirmationResult?> show({
    required BuildContext context,
    required CommandType commandType,
    ControlUserRole userRole = ControlUserRole.operator,
  }) {
    return showDialog<ControlConfirmationResult>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ControlConfirmationDialog(
        commandType: commandType,
        userRole: userRole,
      ),
    );
  }

  @override
  State<ControlConfirmationDialog> createState() => _ControlConfirmationDialogState();
}

class ControlConfirmationResult {
  final bool confirmed;
  final int durationMinutes;
  final ControlUserRole userRole;

  const ControlConfirmationResult({
    required this.confirmed,
    this.durationMinutes = 30,
    required this.userRole,
  });
}

class _ControlConfirmationDialogState extends State<ControlConfirmationDialog> {
  int _selectedDuration = 30;
  late ControlUserRole _activeRole;

  final List<int> _durationOptions = const [15, 30, 45, 60, 90, 120];

  @override
  void initState() {
    super.initState();
    _activeRole = widget.userRole;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isStart = widget.commandType == CommandType.startIrrigation;
    final isUnauthorized = _activeRole == ControlUserRole.viewer;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isStart ? AppColors.pumpActive : AppColors.alertWarning).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isStart ? Icons.play_arrow : Icons.stop,
              color: isStart ? AppColors.pumpActive : AppColors.alertWarning,
            ),
          ),
          const SizedBox(width: AppDimensions.spaceSm),
          Expanded(
            child: Text(
              isStart ? 'Start Field Irrigation?' : 'Stop Field Irrigation?',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Target Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.center_focus_strong, color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Target Scope: ',
                    style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    CentralControlTelemetry.fixedTarget,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spaceMd),

            // Safety disclaimer banner
            Container(
              padding: const EdgeInsets.all(AppDimensions.spaceSm),
              decoration: BoxDecoration(
                color: isStart
                    ? AppColors.alertWarning.withValues(alpha: 0.1)
                    : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                border: Border.all(
                  color: isStart
                      ? AppColors.alertWarning.withValues(alpha: 0.4)
                      : AppColors.primary.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: isStart ? AppColors.alertWarning : AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isStart
                          ? 'Safety Warning: Centralized irrigation applies to the entire rice field. Main pump and valve hardware will engage.'
                          : 'Immediate Action: Stopping irrigation will shut off the main pump and close the central distribution valve.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (isStart) ...[
              const SizedBox(height: AppDimensions.spaceMd),
              Text(
                'Select Duration:',
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _durationOptions.map((minutes) {
                  final isSelected = _selectedDuration == minutes;
                  return ChoiceChip(
                    label: Text('${minutes}m'),
                    selected: isSelected,
                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.primary : null,
                      fontWeight: isSelected ? FontWeight.bold : null,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedDuration = minutes);
                      }
                    },
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: AppDimensions.spaceMd),
            Text(
              'Authorization Role:',
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            DropdownButton<ControlUserRole>(
              value: _activeRole,
              isExpanded: true,
              items: const [
                DropdownMenuItem(
                  value: ControlUserRole.operator,
                  child: Text('Operator (Authorized)'),
                ),
                DropdownMenuItem(
                  value: ControlUserRole.admin,
                  child: Text('Admin (Authorized)'),
                ),
                DropdownMenuItem(
                  value: ControlUserRole.viewer,
                  child: Text('Viewer (Read-Only • Unauthorized)'),
                ),
              ],
              onChanged: (role) {
                if (role != null) {
                  setState(() => _activeRole = role);
                }
              },
            ),

            if (isUnauthorized) ...[
              const SizedBox(height: 8),
              Text(
                '⚠️ Viewer role cannot execute hardware control commands.',
                style: theme.textTheme.bodySmall?.copyWith(color: AppColors.alertError),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: isUnauthorized
              ? null
              : () => Navigator.of(context).pop(
                    ControlConfirmationResult(
                      confirmed: true,
                      durationMinutes: _selectedDuration,
                      userRole: _activeRole,
                    ),
                  ),
          style: ElevatedButton.styleFrom(
            backgroundColor: isStart ? AppColors.pumpActive : AppColors.alertWarning,
            foregroundColor: Colors.white,
          ),
          child: Text(isStart ? 'Confirm Start' : 'Confirm Stop'),
        ),
      ],
    );
  }
}
