import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/widgets.dart';
import '../domain/models/models.dart';
import 'providers/central_control_provider.dart';
import 'widgets/control_confirmation_dialog.dart';

class ControlScreen extends StatefulWidget {
  final CentralControlNotifier? notifier;

  const ControlScreen({super.key, this.notifier});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  late CentralControlNotifier _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = widget.notifier ?? CentralControlNotifier();
    _notifier.addListener(_onStateChanged);
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
          ],
        ),
      ),
    );
  }

  Widget _buildAlertBanners(CentralControlStateData state, CentralControlTelemetry? telemetry) {
    final banners = <Widget>[];

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
              const SizedBox(width: AppDimensions.spaceSm),
              Expanded(
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
