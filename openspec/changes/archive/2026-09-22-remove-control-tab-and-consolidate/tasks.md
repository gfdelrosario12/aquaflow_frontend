## 1. App Shell and Navigation Updates

- [x] 1.1 Update `lib/features/shell/presentation/app_shell.dart` to remove Control tab, setting up 4 navigation tabs (Home, Field, Manual Control, Settings).
- [x] 1.2 Update `lib/features/home/presentation/home_screen.dart` navigation callbacks (`onNavigateToControl`) to target tab index 2 (Manual Control).

## 2. Field Screen Hardware Status Integration

- [x] 2.1 Add central controller and hardware actuator telemetry card (Main Pump, Main Valve, Line Flow Rate, Line Pressure) to `lib/features/field/presentation/field_screen.dart`.

## 3. Manual Control Screen Enhancement & Control Consolidation

- [x] 3.1 Incorporate `CentralControlNotifier`, `AutomationSupervisorCard`, central field control action dispatch buttons, and fault lockout clearing into `lib/features/irrigation/presentation/manual_control_screen.dart`.
- [x] 3.2 Remove obsolete `lib/features/control/presentation/control_screen.dart`.

## 4. Verification & Testing

- [x] 4.1 Update widget and unit test suites for 4-tab app shell, updated field screen, and consolidated manual control screen.
- [x] 4.2 Run `flutter test` across the codebase to ensure zero regressions.

