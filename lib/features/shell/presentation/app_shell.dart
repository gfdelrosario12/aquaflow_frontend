import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../alerts/presentation/alerts_screen.dart';
import '../../analytics/presentation/analytics_screen.dart';
import '../../control/presentation/control_screen.dart';
import '../../diagnostics/presentation/device_diagnostics_screen.dart';
import '../../field/presentation/field_screen.dart';
import '../../home/presentation/home_screen.dart';
import '../../settings/presentation/settings_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  void _onTabSelected(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(
        onNavigateToControl: () => _onTabSelected(3),
        onNavigateToField: () => _onTabSelected(1),
      ),
      const FieldScreen(),
      const AnalyticsScreen(),
      const ControlScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _currentIndex == 0
              ? AppStrings.appTitle
              : (_currentIndex == 1
                  ? AppStrings.navField
                  : (_currentIndex == 2
                      ? AppStrings.navAnalytics
                      : (_currentIndex == 3 ? AppStrings.navControl : AppStrings.navSettings))),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.health_and_safety_outlined),
            tooltip: 'Device Diagnostics',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DeviceDiagnosticsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Badge(
              label: Text('2'),
              child: Icon(Icons.notifications_outlined),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AlertsScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: screens,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabSelected,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: AppStrings.navHome,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_outlined),
              activeIcon: Icon(Icons.grid_view),
              label: AppStrings.navField,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined),
              activeIcon: Icon(Icons.analytics),
              label: AppStrings.navAnalytics,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_remote_outlined),
              activeIcon: Icon(Icons.settings_remote),
              label: AppStrings.navControl,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: AppStrings.navSettings,
            ),
          ],
        ),
      ),
    );
  }
}
