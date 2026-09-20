import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/widgets.dart';
import '../../../features/auth/domain/models/user_role.dart';
import '../../irrigation/domain/models/auto_irrigation_config.dart';
import '../../irrigation/domain/models/auto_irrigation_status.dart';
import '../../irrigation/presentation/providers/irrigation_notifier.dart';
import '../domain/models/models.dart';
import 'providers/central_control_provider.dart';
import 'widgets/auto_irrigation_config_dialog.dart';
import 'widgets/control_confirmation_dialog.dart';
import 'widgets/irrigation_audit_log_section.dart';

class ControlScreen extends StatefulWidget {
  final CentralControlNotifier? notifier;
  final IrrigationNotifier? irrigationNotifier;

  const ControlScreen({
    super.key,
    this.notifier,
    this.irrigationNotifier,
  });

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  late CentralControlNotifier _notifier;
  late IrrigationNotifier _irrigationNotifier;

  @override
  void initState() {
    super.initState();
    _notifier = widget.notifier ?? CentralControlNotifier();
    _notifier.addListener(_onStateChanged);
    _irrigationNotifier = widget.irrigationNotifier ?? IrrigationNotifier();
    _irrigationNotifier.addListener(_onStateChanged);
    _irrigationNotifier.loadAutoIrrigationData();
  }

  void _onStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    if (widget.notifier == null) {
      _notifier.dispose();
    } else {
      _notifier.removeListener(_onStateChanged);
    }
    if (widget.irrigationNotifier == null) {
      _irrigationNotifier.dispose();
    } else {
      _irrigationNotifier.removeListener(_onStateChanged);
    }
    super.dispose();
  }

  Future<void> _handleStartIrrigation() async {
    final result = await ControlConfirmationDialog.show(
      context: context,
      commandType: CommandType.startIrrigation,
      userRole: _notifier.state.userRole,
    );

    if (result != null && result.confirmed) {
      final cmdResult = await _notifier.startIrrigation(
        durationMinutes: result.durationMinutes,
        requestedBy: 'Field Operator',
        role: result.userRole,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(cmdResult.message),
            backgroundColor: cmdResult.isSuccess ? AppColors.pumpActive : AppColors.alertError,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleStopIrrigation() async {
    final result = await ControlConfirmationDialog.show(
      context: context,
      commandType: CommandType.stopIrrigation,
      userRole: _notifier.state.userRole,
    );

    if (result != null && result.confirmed) {
      final cmdResult = await _notifier.stopIrrigation(
        requestedBy: 'Field Operator',
        role: result.userRole,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(cmdResult.message),
            backgroundColor: cmdResult.isSuccess ? AppColors.primary : AppColors.alertError,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleConfigureAutomation() async {
    final updated = await AutoIrrigationConfigDialog.show(
      context,
      _irrigationNotifier.state.config,
    );
    if (updated != null) {
      final ok = await _irrigationNotifier.updateConfig(updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ok
                ? 'Automation configuration updated.'
                : 'Failed to update configuration.'),
            backgroundColor: ok ? AppColors.primary : AppColors.alertError,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleClearLockout() async {
    final ok = await _irrigationNotifier.clearFaultLockout(
      clearedBy: _notifier.state.userRole.name,
      resolutionNote: 'Cleared by operator via Control Screen',
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok
              ? 'Fault lockout successfully cleared. Automation restored to standby.'
              : 'Failed to clear fault lockout.'),
          backgroundColor: ok ? AppColors.pumpActive : AppColors.alertError,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = _notifier.state;
    final telemetry = state.telemetry;

    if (state.isLoading && telemetry == null) {
      return const ResponsiveContainer(
        child: LoadingStateWidget(message: 'Connecting to Central Controller Pipeline...'),
      );
    }

    final isControllerOffline = telemetry?.controllerState == CentralControllerState.offline;
    final isEmergencyStop = telemetry?.controllerState == CentralControllerState.emergencyStop;
    final isIrrigating = telemetry?.irrigationState == IrrigationState.irrigating;
    final isPending = state.isCommandPending;

    return ResponsiveContainer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Screen Title & Subtitle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.irrigationControlTitle,
                        style: theme.textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Centralized physical irrigation serving the entire field',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on, color: AppColors.primary, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'TARGET: ${CentralControlTelemetry.fixedTarget}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spaceMd),

            // Automation Supervisor Card
            _buildAutoSupervisorCard(),
            const SizedBox(height: AppDimensions.spaceMd),

            // Fault Banners & Warnings
            _buildAlertBanners(state, telemetry),

            // Hardware Status Card
            _buildHardwareStatusCard(telemetry),
            const SizedBox(height: AppDimensions.spaceMd),

            // Command Control Card
            _buildActionControlCard(isIrrigating, isPending, isControllerOffline, isEmergencyStop),
            const SizedBox(height: AppDimensions.spaceMd),

            // Last Command & Pipeline Audit Log
            if (telemetry?.lastCommandResult != null) ...[
              _buildLastCommandResultCard(telemetry!.lastCommandResult!),
              const SizedBox(height: AppDimensions.spaceMd),
            ],

            // Pipeline Telemetry & Architecture Card
            _buildTelemetryCard(telemetry),
            const SizedBox(height: AppDimensions.spaceMd),

            // Irrigation Execution Audit Log Section
            IrrigationAuditLogSection(
              auditLogs: _irrigationNotifier.state.auditLogs,
              onRefresh: () => _irrigationNotifier.loadAutoIrrigationData(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAutoSupervisorCard() {
    final theme = Theme.of(context);
    final autoState = _irrigationNotifier.state;
    final status = autoState.status;
    final config = autoState.config;

    Color badgeColor;
    IconData badgeIcon;
    switch (status.state) {
      case AutoIrrigationState.disabled:
        badgeColor = theme.hintColor;
        badgeIcon = Icons.power_settings_new;
        break;
      case AutoIrrigationState.standby:
        badgeColor = AppColors.primary;
        badgeIcon = Icons.check_circle_outline;
        break;
      case AutoIrrigationState.evaluating:
        badgeColor = Colors.orange.shade700;
        badgeIcon = Icons.sync;
        break;
      case AutoIrrigationState.pendingAck:
        badgeColor = Colors.amber.shade800;
        badgeIcon = Icons.hourglass_top;
        break;
      case AutoIrrigationState.irrigating:
        badgeColor = Colors.purple.shade600;
        badgeIcon = Icons.smart_toy;
        break;
      case AutoIrrigationState.cooldown:
        badgeColor = Colors.teal.shade700;
        badgeIcon = Icons.timelapse;
        break;
      case AutoIrrigationState.faultLocked:
        badgeColor = AppColors.alertError;
        badgeIcon = Icons.lock;
        break;
    }

    final remainingCooldown = status.remainingCooldown();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 480;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            side: BorderSide(color: badgeColor.withValues(alpha: 0.3)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spaceMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(badgeIcon, color: badgeColor, size: 22),
                          const SizedBox(width: AppDimensions.spaceSm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Automation Supervisor',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Centralized field-level autonomous control',
                                  style: theme.textTheme.bodySmall,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spaceSm),
                    // Supervisor State Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                        border: Border.all(color: badgeColor.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: badgeColor,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            status.state.label.toUpperCase(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: badgeColor,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spaceSm),
                const Divider(),
                const SizedBox(height: AppDimensions.spaceSm),
                // Details & Actions
                if (isNarrow) ...[
                  _buildSupervisorDetails(status, config, remainingCooldown, theme),
                  const SizedBox(height: AppDimensions.spaceSm),
                  Wrap(
                    spacing: AppDimensions.spaceSm,
                    runSpacing: AppDimensions.spaceSm,
                    children: [
                      if (status.isFaultLocked)
                        AuthorizationGate(
                          requiredRole: UserRole.operator,
                          child: FilledButton.tonalIcon(
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.alertError.withValues(alpha: 0.15),
                              foregroundColor: AppColors.alertError,
                            ),
                            icon: const Icon(Icons.lock_open, size: 16),
                            label: const Text('Clear Lockout'),
                            onPressed: _handleClearLockout,
                          ),
                        ),
                      AuthorizationGate(
                        requiredRole: UserRole.operator,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.tune, size: 16),
                          label: const Text('Configure'),
                          onPressed: _handleConfigureAutomation,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _buildSupervisorDetails(status, config, remainingCooldown, theme),
                      ),
                      const SizedBox(width: AppDimensions.spaceSm),
                      Row(
                        children: [
                          if (status.isFaultLocked) ...[
                            AuthorizationGate(
                              requiredRole: UserRole.operator,
                              child: FilledButton.tonalIcon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.alertError.withValues(alpha: 0.15),
                                  foregroundColor: AppColors.alertError,
                                ),
                                icon: const Icon(Icons.lock_open, size: 16),
                                label: const Text('Clear Lockout'),
                                onPressed: _handleClearLockout,
                              ),
                            ),
                            const SizedBox(width: AppDimensions.spaceSm),
                          ],
                          AuthorizationGate(
                            requiredRole: UserRole.operator,
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.tune, size: 16),
                              label: const Text('Configure'),
                              onPressed: _handleConfigureAutomation,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSupervisorDetails(
    AutoIrrigationStatus status,
    AutoIrrigationConfig config,
    Duration? remainingCooldown,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (status.isInCooldown && remainingCooldown != null) ...[
          Row(
            children: [
              const Icon(Icons.timer_outlined, size: 16, color: Colors.teal),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Cooldown Active: ${remainingCooldown.inMinutes}m ${remainingCooldown.inSeconds % 60}s remaining',
                  style: const TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
        if (status.isActivelyIrrigating) ...[
          Row(
            children: [
              Icon(Icons.play_circle_outline, size: 16, color: Colors.purple.shade600),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Auto-Irrigation In Progress (Target: ${status.targetDurationMinutes ?? config.maxDurationMinutes}m)',
                  style: TextStyle(
                    color: Colors.purple.shade600,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
        if (status.isFaultLocked) ...[
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.alertError),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Lockout: ${status.lockoutReason ?? "Hardware or ACK timeout"}',
                  style: const TextStyle(
                    color: AppColors.alertError,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
        Text(
          config.isEnabled
              ? 'Window: ${config.allowedHoursStart.toString().padLeft(2, "0")}:00 - ${config.allowedHoursEnd.toString().padLeft(2, "0")}:00 • Max: ${config.maxDurationMinutes}m • Cooldown: ${config.minCooldownMinutes}m'
              : 'Field automation is currently disabled by operator.',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildAlertBanners(CentralControlStateData state, CentralControlTelemetry? telemetry) {
    final banners = <Widget>[];

    final autoState = _irrigationNotifier.state;
    final autoStatus = autoState.status;

    if (autoStatus.isFaultLocked) {
      banners.add(
        _buildBannerItem(
          icon: Icons.lock,
          color: AppColors.alertError,
          title: 'Automation Fault Locked',
          message:
              'Safety lockout engaged: ${autoStatus.lockoutReason ?? "Unacknowledged hardware/command failure"}. Remote automation paused until cleared.',
        ),
      );
    }

    if (autoStatus.isInCooldown) {
      final remaining = autoStatus.remainingCooldown();
      final remainingText = remaining != null
          ? ' (${remaining.inMinutes}m ${remaining.inSeconds % 60}s remaining)'
          : '';
      banners.add(
        _buildBannerItem(
          icon: Icons.timelapse,
          color: Colors.teal.shade700,
          title: 'Soil Infiltration Cooldown Active$remainingText',
          message:
              'Centralized pump is cooling down to allow soil moisture absorption and prevent waterlogging.',
        ),
      );
    }

    if (autoStatus.isActivelyIrrigating) {
      banners.add(
        _buildBannerItem(
          icon: Icons.smart_toy,
          color: Colors.purple.shade600,
          title: 'Automated AWD Irrigation In Progress',
          message:
              'Automated cycle initiated by AWD rule engine. Hardware watchdog timer is actively guarding pump shutoff.',
        ),
      );
    }

    if (telemetry?.controllerState == CentralControllerState.offline) {
      banners.add(
        _buildBannerItem(
          icon: Icons.cloud_off,
          color: AppColors.alertError,
          title: 'Central Controller OFFLINE',
          message: 'LoRaWAN messaging link unestablished. Remote control commands disabled until reconnected.',
        ),
      );
    }

    if (telemetry?.controllerState == CentralControllerState.emergencyStop) {
      banners.add(
        _buildBannerItem(
          icon: Icons.emergency,
          color: AppColors.alertError,
          title: 'Physical Emergency Stop Engaged',
          message: 'Local physical override active at main pump. Remote app commands locked out for safety.',
        ),
      );
    }

    if (telemetry?.isStale == true) {
      banners.add(
        _buildBannerItem(
          icon: Icons.history_toggle_off,
          color: AppColors.alertWarning,
          title: 'Stale Telemetry Warning',
          message: 'Controller status telemetry is older than expected. Displayed status may not reflect active state.',
        ),
      );
    }

    if (state.isCommandPending) {
      banners.add(
        _buildBannerItem(
          icon: Icons.hourglass_top,
          color: AppColors.primary,
          title: 'Command Pipeline Pending',
          message: 'Control command in-flight over LoRaWAN network. Concurrency lock active.',
        ),
      );
    }

    if (state.errorMessage != null) {
      banners.add(
        _buildBannerItem(
          icon: Icons.error_outline,
          color: AppColors.alertError,
          title: 'Command Error',
          message: state.errorMessage!,
        ),
      );
    }

    if (banners.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        ...banners,
        const SizedBox(height: AppDimensions.spaceMd),
      ],
    );
  }

  Widget _buildBannerItem({
    required IconData icon,
    required Color color,
    required String title,
    required String message,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceSm),
      padding: const EdgeInsets.all(AppDimensions.spaceSm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: AppDimensions.spaceSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHardwareStatusCard(CentralControlTelemetry? telemetry) {
    final theme = Theme.of(context);

    final pumpText = telemetry?.pumpStatus == PumpStatus.pumping
        ? 'PUMPING'
        : (telemetry?.pumpStatus == PumpStatus.fault ? 'FAULT' : 'OFF');

    final valveText = telemetry?.valveStatus == MainValveStatus.open
        ? 'OPEN'
        : (telemetry?.valveStatus == MainValveStatus.transitioning ? 'TRANSITIONING' : 'CLOSED');

    final ctrlText = telemetry?.controllerState == CentralControllerState.online
        ? 'ONLINE'
        : (telemetry?.controllerState == CentralControllerState.emergencyStop ? 'EMERGENCY STOP' : 'OFFLINE');

    return AquaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Central Controller & Actuators',
                  style: theme.textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppDimensions.spaceSm),
              StatusBadge.deviceStatus(
                ctrlText,
                compact: true,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceMd),
          Row(
            children: [
              Expanded(
                child: SensorMetricTile(
                  label: 'Main Pump',
                  value: pumpText,
                  icon: Icons.power_settings_new,
                  color: telemetry?.pumpStatus == PumpStatus.pumping ? AppColors.pumpActive : AppColors.primary,
                ),
              ),
              Expanded(
                child: SensorMetricTile(
                  label: 'Main Valve',
                  value: valveText,
                  icon: Icons.alt_route,
                  color: telemetry?.valveStatus == MainValveStatus.open ? AppColors.valveOpen : AppColors.primary,
                ),
              ),
              Expanded(
                child: SensorMetricTile(
                  label: 'Irrigation State',
                  value: telemetry?.irrigationState.name.toUpperCase() ?? 'IDLE',
                  icon: Icons.water_drop,
                  color: telemetry?.irrigationState == IrrigationState.irrigating ? AppColors.pumpActive : AppColors.primary,
                ),
              ),
            ],
          ),
          if (telemetry?.startTime != null && telemetry?.durationMinutes != null) ...[
            const SizedBox(height: AppDimensions.spaceSm),
            const Divider(),
            const SizedBox(height: AppDimensions.spaceSm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Started: ${_formatTime(telemetry!.startTime!)}',
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  'Duration: ${telemetry.durationMinutes} minutes',
                  style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionControlCard(bool isIrrigating, bool isPending, bool isOffline, bool isEmergencyStop) {
    final theme = Theme.of(context);
    final isDisabled = isPending || isOffline || isEmergencyStop;

    return AquaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Central Field Control Actions',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Dispatch commands to the single physical field irrigation system',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: AppDimensions.spaceMd),
          Row(
            children: [
              Expanded(
                child: AuthorizationGate(
                  requiredRole: UserRole.operator,
                  child: ElevatedButton.icon(
                    onPressed: isDisabled || isIrrigating ? null : _handleStartIrrigation,
                    icon: isPending && !isIrrigating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.play_arrow),
                    label: const Text('Start Field Irrigation'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: AppColors.pumpActive,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.spaceSm),
              Expanded(
                child: AuthorizationGate(
                  requiredRole: UserRole.operator,
                  child: ElevatedButton.icon(
                    onPressed: isDisabled || !isIrrigating ? null : _handleStopIrrigation,
                    icon: isPending && isIrrigating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.stop),
                    label: const Text('Stop Field Irrigation'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: AppColors.alertWarning,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLastCommandResultCard(ControlCommandResult result) {
    final theme = Theme.of(context);

    return AquaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Last Command Outcome',
                  style: theme.textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppDimensions.spaceSm),
              StatusBadge.deviceStatus(
                result.outcome.name.toUpperCase(),
                compact: true,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceSm),
          Text(
            result.message,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 6),
          Text(
            'ID: ${result.commandId} • Timestamp: ${_formatTime(result.timestamp)}',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6)),
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryCard(CentralControlTelemetry? telemetry) {
    final theme = Theme.of(context);

    return AquaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hardware & Pipeline Diagnostics',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppDimensions.spaceMd),
          Row(
            children: [
              Expanded(
                child: SensorMetricTile(
                  label: 'Line Flow Rate',
                  value: (telemetry?.flowRateLitersPerMin ?? 0.0).toStringAsFixed(1),
                  unit: 'L/min',
                  icon: Icons.speed,
                  color: AppColors.primary,
                ),
              ),
              Expanded(
                child: SensorMetricTile(
                  label: 'Line Pressure',
                  value: (telemetry?.linePressureBar ?? 0.0).toStringAsFixed(1),
                  unit: 'bar',
                  icon: Icons.compress,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceSm),
          const Divider(),
          const SizedBox(height: AppDimensions.spaceSm),
          Row(
            children: [
              const Icon(Icons.account_tree, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Pipeline Path: Mobile App → Backend API → LoRaWAN Gateway → Central Controller → Pump/Valve',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    final sec = dt.second.toString().padLeft(2, '0');
    return '$hour:$min:$sec';
  }
}
