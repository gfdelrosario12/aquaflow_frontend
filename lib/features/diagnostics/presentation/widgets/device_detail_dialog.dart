import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../control/presentation/control_screen.dart';
import '../../domain/models/models.dart';

class DeviceDetailDialog extends StatelessWidget {
  final DeviceDiagnostic device;

  const DeviceDetailDialog({
    super.key,
    required this.device,
  });

  static Future<void> show(BuildContext context, DeviceDiagnostic device) {
    return showDialog(
      context: context,
      builder: (context) => DeviceDetailDialog(device: device),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isController = device.category == DeviceCategory.centralController;
    final isNode = device.category == DeviceCategory.sensorNode;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      title: Row(
        children: [
          Icon(
            isController ? Icons.settings_remote : (isNode ? Icons.sensors : Icons.router),
            color: AppColors.primary,
          ),
          const SizedBox(width: AppDimensions.spaceSm),
          Expanded(
            child: Text(
              device.name,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Scope & Health Badges Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StatusBadge.deviceStatus(
                  device.healthStatus.name.toUpperCase(),
                  compact: true,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    'SCOPE: ${device.targetScope}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spaceMd),

            // Hardware Telemetry Metrics Grid
            if (device.batteryPercent != null || device.rssiDbm != null) ...[
              Row(
                children: [
                  if (device.batteryPercent != null)
                    Expanded(
                      child: SensorMetricTile(
                        label: 'Battery Level',
                        value: '${device.batteryPercent}% (${device.batteryVoltage?.toStringAsFixed(2)}V)',
                        icon: Icons.battery_charging_full,
                        color: (device.batteryPercent ?? 100) < 20 ? AppColors.alertWarning : AppColors.primary,
                      ),
                    ),
                  if (device.rssiDbm != null)
                    Expanded(
                      child: SensorMetricTile(
                        label: 'RF Signal',
                        value: '${device.rssiDbm} dBm',
                        unit: 'SNR ${device.snrDb?.toStringAsFixed(1)} dB',
                        icon: Icons.cell_tower,
                        color: (device.rssiDbm ?? -90) < -100 ? AppColors.alertWarning : AppColors.primary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppDimensions.spaceSm),
            ],

            if (device.lastMeasurement != null) ...[
              Text(
                'Latest Telemetry Measurement:',
                style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                device.lastMeasurement!,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppDimensions.spaceSm),
            ],

            // Diagnostics Message Box
            Container(
              padding: const EdgeInsets.all(AppDimensions.spaceSm),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.build, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      device.diagnosticMessage,
                      style: theme.textTheme.bodySmall?.copyWith(height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spaceSm),

            Text(
              'Last Heartbeat Seen: ${_formatTime(device.lastSeen)}',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: AppDimensions.spaceSm),
            if (isNode)
              _buildReadOnlyNotice(theme)
            else if (device.category == DeviceCategory.gateway)
              _buildGatewayDetails(theme)
            else
              _buildControllerDetails(theme),
          ],
        ),
      ),
      actions: [
        if (isController)
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ControlScreen()),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Open Control Screen'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    final sec = dt.second.toString().padLeft(2, '0');
    return '$hour:$min:$sec';
  }

  Widget _buildReadOnlyNotice(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceSm),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      child: Row(
        children: [
          const Icon(Icons.visibility_outlined, size: 18, color: AppColors.primary),
          const SizedBox(width: AppDimensions.spaceSm),
          Expanded(
            child: Text(
              'Read-only telemetry node. Q1–Q4 do not control pumps or irrigation valves.',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGatewayDetails(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Network health', style: theme.textTheme.titleSmall),
        const SizedBox(height: AppDimensions.spaceSm),
        _detailRow('Connectivity', device.communicationStatus ?? 'N/A'),
        _detailRow('Uplink', device.uplinkStatus ?? 'N/A'),
        _detailRow('Downlink', device.downlinkStatus ?? 'N/A'),
        _detailRow('Backhaul', device.backhaulStatus ?? 'N/A'),
        _detailRow('Retransmission', device.packetRetransmissionRate == null ? 'N/A' : '${device.packetRetransmissionRate!.toStringAsFixed(1)}%'),
        _detailRow('Last communication', _formatTime(device.lastCommunication ?? device.lastSeen)),
      ],
    );
  }

  Widget _buildControllerDetails(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Central controller diagnostics', style: theme.textTheme.titleSmall),
        const SizedBox(height: AppDimensions.spaceSm),
        _detailRow('Communication', device.communicationStatus ?? 'N/A'),
        _detailRow('Pump state', device.pumpState ?? 'N/A'),
        _detailRow('Main valve', device.valveState ?? 'N/A'),
        _detailRow('Last command', device.lastCommand ?? 'N/A'),
        _detailRow('Command result', device.lastCommandResult ?? 'N/A'),
        _detailRow('Last communication', _formatTime(device.lastCommunication ?? device.lastSeen)),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spaceXs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 132, child: Text(label)),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
