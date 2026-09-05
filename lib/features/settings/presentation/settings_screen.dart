import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/widgets.dart';
import '../../../main.dart';
import '../../auth/presentation/controllers/auth_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await AquaDialog.show(
      context: context,
      title: 'Sign Out of AquaFlow?',
      message: 'Are you sure you want to end your operator session?',
      confirmText: 'Sign Out',
      icon: Icons.logout,
      iconColor: AppColors.alertError,
    );

    if (confirmed == true) {
      await globalAuthNotifier.logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ResponsiveContainer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'App Settings',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Application configuration & system preferences',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppDimensions.spaceMd),
            _buildUserSessionCard(context),
            const SizedBox(height: AppDimensions.spaceMd),
            _buildThemeToggleSection(context),
            const SizedBox(height: AppDimensions.spaceMd),
            _buildSettingsSection(
              context,
              'System Architecture',
              [
                _buildSettingsTile(
                  context,
                  'Application Name',
                  AppStrings.appTitle,
                  Icons.water_drop,
                ),
                _buildSettingsTile(
                  context,
                  'App Version',
                  '1.0.0+1 (Auth Release)',
                  Icons.info_outline,
                ),
                _buildSettingsTile(
                  context,
                  'Data Source Mode',
                  'Mock Service / REST HTTPS Ready',
                  Icons.cloud_outlined,
                ),
                _buildSettingsTile(
                  context,
                  'Target Viewport',
                  '360px – 430px Android Layout',
                  Icons.phone_android,
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spaceMd),
            _buildSettingsSection(
              context,
              'Telemetry Settings',
              [
                _buildSettingsTile(
                  context,
                  'Monitoring Zones',
                  'Q1, Q2, Q3, Q4 (Active)',
                  Icons.sensors,
                ),
                _buildSettingsTile(
                  context,
                  'Irrigation Scope',
                  'Central Field Physical System',
                  Icons.water_drop_outlined,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserSessionCard(BuildContext context) {
    final theme = Theme.of(context);

    return ValueListenableBuilder<AuthState>(
      valueListenable: globalAuthNotifier,
      builder: (context, authState, _) {
        final session = authState.session;

        return AquaCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.account_circle_outlined,
                          color: AppColors.primary, size: 24),
                      const SizedBox(width: AppDimensions.spaceSm),
                      Text(
                        'Active Operator Session',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                  StatusBadge(
                    label: session?.role.toUpperCase() ?? 'OPERATOR',
                    colorOverride: AppColors.primary,
                    isCompact: true,
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spaceMd),
              if (session != null) ...[
                Row(
                  children: [
                    Expanded(
                      child: SensorMetricTile(
                        label: 'Operator Name',
                        value: session.username,
                        icon: Icons.person,
                        color: AppColors.primary,
                      ),
                    ),
                    Expanded(
                      child: SensorMetricTile(
                        label: 'Email',
                        value: session.email,
                        icon: Icons.email,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spaceMd),
              ],
              AquaButton(
                label: 'Sign Out Operator',
                icon: Icons.logout,
                variant: AquaButtonVariant.outline,
                onPressed: () => _handleLogout(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeToggleSection(BuildContext context) {
    final theme = Theme.of(context);

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, currentMode, _) {
        final isDark = currentMode == ThemeMode.dark;

        return AquaCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        isDark ? Icons.dark_mode : Icons.light_mode,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppDimensions.spaceSm),
                      Text(
                        'Visual Theme Mode',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                  StatusBadge(
                    label: isDark ? 'DARK MODE' : 'LIGHT MODE',
                    colorOverride: isDark ? AppColors.primary : AppColors.primaryDark,
                    isCompact: true,
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spaceMd),
              AquaChipSelector<ThemeMode>(
                options: const [
                  AquaChipOption(
                    value: ThemeMode.dark,
                    label: 'Dark Theme (Default)',
                    icon: Icons.dark_mode,
                  ),
                  AquaChipOption(
                    value: ThemeMode.light,
                    label: 'Light Theme',
                    icon: Icons.light_mode,
                  ),
                ],
                selectedValue: currentMode,
                onSelected: (mode) {
                  themeModeNotifier.value = mode;
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingsSection(
    BuildContext context,
    String title,
    List<Widget> tiles,
  ) {
    return AquaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                ),
          ),
          const SizedBox(height: AppDimensions.spaceSm),
          const Divider(),
          ...tiles,
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context,
    String label,
    String subtitle,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spaceSm),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.textTheme.bodyMedium?.color),
          const SizedBox(width: AppDimensions.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.titleSmall,
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
