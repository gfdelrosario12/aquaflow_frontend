import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/aqua_button.dart';
import '../../../control/domain/models/control_enums.dart';
import '../../domain/models/models.dart';

class TransmissionIntervalDialog extends StatefulWidget {
  final Esp32Node node;
  final ControlUserRole userRole;
  final Future<bool> Function(
    int intervalSeconds, {
    bool isAdaptive,
    String? reason,
  }) onConfigure;

  const TransmissionIntervalDialog({
    super.key,
    required this.node,
    required this.userRole,
    required this.onConfigure,
  });

  static Future<bool?> show(
    BuildContext context, {
    required Esp32Node node,
    required ControlUserRole userRole,
    required Future<bool> Function(
      int intervalSeconds, {
      bool isAdaptive,
      String? reason,
    }) onConfigure,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => TransmissionIntervalDialog(
        node: node,
        userRole: userRole,
        onConfigure: onConfigure,
      ),
    );
  }

  @override
  State<TransmissionIntervalDialog> createState() =>
      _TransmissionIntervalDialogState();
}

class _TransmissionIntervalDialogState extends State<TransmissionIntervalDialog> {
  late int _selectedInterval;
  late bool _isAdaptive;
  final _reasonController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedInterval = widget.node.transmissionConfig.intervalSeconds;
    _isAdaptive = widget.node.transmissionConfig.isAdaptive;
    _reasonController.text = widget.node.transmissionConfig.adaptiveReason ?? '';
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  bool get _isAuthorized =>
      widget.userRole == ControlUserRole.admin ||
      widget.userRole == ControlUserRole.operator;

  Future<void> _submit() async {
    if (!_isAuthorized) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await widget.onConfigure(
      _selectedInterval,
      isAdaptive: _isAdaptive,
      reason: _reasonController.text.trim().isNotEmpty
          ? _reasonController.text.trim()
          : null,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to configure transmission interval.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final presets = [
      (30, '30s (Rapid Alert)'),
      (60, '1m (Active Monitor)'),
      (300, '5m (Standard)'),
      (900, '15m (Power Save)'),
      (3600, '1h (Low Duty)'),
    ];

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      title: Row(
        children: [
          const Icon(Icons.timer_outlined, color: AppColors.primary),
          const SizedBox(width: AppDimensions.spaceSm),
          Expanded(
            child: Text(
              'Transmission Interval',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Node: ${widget.node.displayName}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'MAC: ${widget.node.macAddress}',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: AppDimensions.spaceMd),

            // Authorization Warning Banner for Viewers
            if (!_isAuthorized) ...[
              Container(
                padding: const EdgeInsets.all(AppDimensions.spaceSm),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline, size: 18, color: AppColors.error),
                    const SizedBox(width: AppDimensions.spaceSm),
                    Expanded(
                      child: Text(
                        'Viewer role is read-only. Operator or Admin authorization is required to change transmission intervals.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.error,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.spaceMd),
            ],

            if (_errorMessage != null) ...[
              Text(
                _errorMessage!,
                style: const TextStyle(color: AppColors.error, fontSize: 12),
              ),
              const SizedBox(height: AppDimensions.spaceSm),
            ],

            // Interval Presets
            Text(
              'Select Base Reporting Interval:',
              style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...presets.map((preset) {
              final val = preset.$1;
              final label = preset.$2;
              return RadioListTile<int>(
                value: val,
                groupValue: _selectedInterval,
                onChanged: _isAuthorized && !_isLoading
                    ? (v) => setState(() => _selectedInterval = v ?? 300)
                    : null,
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(label, style: const TextStyle(fontSize: 13)),
              );
            }),
            const Divider(),

            // Adaptive Interval Toggle
            SwitchListTile(
              value: _isAdaptive,
              onChanged: _isAuthorized && !_isLoading
                  ? (v) => setState(() => _isAdaptive = v)
                  : null,
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Adaptive Dynamic Interval',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Allows backend to automatically accelerate rates during dry-down or slow down to save battery.',
                style: TextStyle(fontSize: 11),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        if (_isAuthorized)
          AquaButton(
            label: _isLoading ? 'Updating...' : 'Save Interval',
            icon: Icons.check,
            onPressed: _isLoading ? null : _submit,
          ),
      ],
    );
  }
}

