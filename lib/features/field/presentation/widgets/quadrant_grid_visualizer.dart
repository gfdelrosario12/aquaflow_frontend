import 'package:flutter/material.dart';
import '../../../zones/domain/models/monitoring_zone.dart';
import 'dynamic_zone_grid_visualizer.dart';

/// Legacy visualizer for quadrant monitoring zones.
///
/// Deprecated in favor of [DynamicZoneGridVisualizer], which supports arbitrary
/// numbers of monitoring zones (1, 2, 4, 6, 8, etc.) and adaptive responsive layouts.
@Deprecated('Use DynamicZoneGridVisualizer instead')
class QuadrantGridVisualizer extends StatelessWidget {
  final List<MonitoringZone> zones;
  final ValueChanged<MonitoringZone>? onZoneSelected;
  final String? selectedZoneCode;

  const QuadrantGridVisualizer({
    super.key,
    required this.zones,
    this.onZoneSelected,
    this.selectedZoneCode,
  });

  @override
  Widget build(BuildContext context) {
    return DynamicZoneGridVisualizer(
      zones: zones,
      onZoneSelected: onZoneSelected,
      selectedZoneCode: selectedZoneCode,
    );
  }
}
