import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/widgets.dart';
import '../../irrigation/data/repositories/irrigation_repository.dart';
import '../../irrigation/domain/models/centralized_irrigation.dart';

class ControlScreen extends StatefulWidget {
  const ControlScreen({super.key});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  final IrrigationRepository _repository = IrrigationRepositoryImpl();
  bool _isLoading = true;
  CentralizedIrrigation? _system;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    setState(() => _isLoading = true);
    final status = await _repository.fetchSystemStatus();
    if (mounted) {
      setState(() {
        _system = status;
        _isLoading = false;
      });
    }
  }

  Future<void> _togglePump(bool value) async {
    final confirmed = await AquaDialog.show(
      context: context,
      title: value ? 'Activate Irrigation Pump?' : 'Deactivate Irrigation Pump?',
      message: value
          ? 'This will initiate field-wide water distribution to all monitored quadrants.'
          : 'This will stop main line water flow immediately.',
      confirmText: value ? 'Start Pump' : 'Stop Pump',
      icon: Icons.power_settings_new,
      iconColor: value ? AppColors.pumpActive : AppColors.alertWarning,
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      final updated = await _repository.toggleMainPump(value);
      if (mounted) {
        setState(() {
          _system = updated;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _changeMode(SystemMode mode) async {
    setState(() => _isLoading = true);
    final updated = await _repository.updateSystemMode(mode);
    if (mounted) {
      setState(() {
        _system = updated;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final system = _system;
    final isPumpActive = system?.mainPumpState == PumpState.active;

    return ResponsiveContainer(
      child: _isLoading
          ? const LoadingStateWidget(message: 'Updating System Controls...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.spaceMd),
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
                  const SizedBox(height: AppDimensions.spaceMd),
                  _buildMainPumpCard(isPumpActive),
                  const SizedBox(height: AppDimensions.spaceMd),
                  _buildSystemModeSelector(system?.mode ?? SystemMode.scheduled),
                  const SizedBox(height: AppDimensions.spaceMd),
                  _buildHardwareMetricsCard(system),
                ],
              ),
            ),
    );
  }

  Widget _buildMainPumpCard(bool isActive) {
    final theme = Theme.of(context);

    return AquaCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.pumpActive.withValues(alpha: 0.2)
                          : AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.power_settings_new,
                      size: AppDimensions.iconLg,
                      color: isActive ? AppColors.pumpActive : AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spaceMd),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.mainPumpLabel,
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(
                        isActive ? 'Running • Direct Irrigation' : 'Idle • Ready',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isActive ? AppColors.pumpActive : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Switch(
                value: isActive,
                onChanged: _togglePump,
                activeThumbColor: AppColors.pumpActive,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceSm),
          const Divider(),
          const SizedBox(height: AppDimensions.spaceSm),
          Text(
            'Simulated override for system architecture demonstration. Direct valve execution triggers main pump flow.',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSystemModeSelector(SystemMode currentMode) {
    final theme = Theme.of(context);

    return AquaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.tune, color: AppColors.primary, size: 20),
                  const SizedBox(width: AppDimensions.spaceSm),
                  Text(
                    AppStrings.modeLabel,
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
              StatusBadge.awdStatus(
                currentMode == SystemMode.simulatedAuto ? 'AWD Active' : 'Manual Mode',
                compact: true,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceMd),
          AquaChipSelector<SystemMode>(
            options: const [
              AquaChipOption(
                value: SystemMode.scheduled,
                label: 'Scheduled',
                icon: Icons.schedule,
              ),
              AquaChipOption(
                value: SystemMode.manual,
                label: 'Manual Override',
                icon: Icons.touch_app,
              ),
              AquaChipOption(
                value: SystemMode.simulatedAuto,
                label: 'AWD Auto',
                icon: Icons.auto_awesome,
              ),
            ],
            selectedValue: currentMode,
            onSelected: _changeMode,
          ),
        ],
      ),
    );
  }

  Widget _buildHardwareMetricsCard(CentralizedIrrigation? system) {
    final theme = Theme.of(context);
    final isValveOpen = system?.distributionValveState == ValveState.open;

    return AquaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'System Hardware Telemetry',
                style: theme.textTheme.titleMedium,
              ),
              StatusBadge.deviceStatus('LoRa Connected', compact: true),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceMd),
          Row(
            children: [
              Expanded(
                child: SensorMetricTile(
                  label: 'Main Line Flow',
                  value: system?.flowRateLitersPerMin.toStringAsFixed(1) ?? "0.0",
                  unit: 'L/min',
                  icon: Icons.speed,
                  color: AppColors.primary,
                ),
              ),
              Expanded(
                child: SensorMetricTile(
                  label: 'Line Pressure',
                  value: system?.pressureBar.toStringAsFixed(1) ?? "0.0",
                  unit: 'bar',
                  icon: Icons.compress,
                  color: AppColors.accent,
                ),
              ),
              Expanded(
                child: SensorMetricTile(
                  label: 'Valve Status',
                  value: isValveOpen ? 'OPEN' : 'CLOSED',
                  icon: Icons.alt_route,
                  color: isValveOpen ? AppColors.valveOpen : AppColors.valveClosed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
