import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/aqua_card.dart';
import '../../../../core/widgets/sensor_metric_tile.dart';
import '../../domain/models/models.dart';
import '../providers/spatial_field_notifier.dart';
import 'node_marker_widget.dart';

class SpatialFieldCanvasVisualizer extends StatefulWidget {
  final List<Esp32Node> nodes;
  final SpatialFieldNotifier? notifier;
  final ValueChanged<Esp32Node>? onNodeSelected;
  final void Function(Esp32Node node)? onConfigureInterval;

  const SpatialFieldCanvasVisualizer({
    super.key,
    required this.nodes,
    this.notifier,
    this.onNodeSelected,
    this.onConfigureInterval,
  });

  @override
  State<SpatialFieldCanvasVisualizer> createState() =>
      _SpatialFieldCanvasVisualizerState();
}

class _SpatialFieldCanvasVisualizerState
    extends State<SpatialFieldCanvasVisualizer> {
  late SpatialFieldNotifier _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = widget.notifier ?? SpatialFieldNotifier();
    _notifier.addListener(_onStateChange);
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    if (widget.notifier == null) {
      _notifier.dispose();
    } else {
      _notifier.removeListener(_onStateChange);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = _notifier.state;

    final selectedNode = state.selectedNodeId != null
        ? widget.nodes
            .where((n) => n.id == state.selectedNodeId)
            .firstOrNull
        : null;

    final unplacedNodes = widget.nodes
        .where((n) => n.coordinates == null || !n.coordinates!.hasAnyCoordinates)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Controls Toolbar
        _buildControlsBar(theme, state),
        const SizedBox(height: AppDimensions.spaceSm),

        // Unplaced nodes warning/chips if any
        if (unplacedNodes.isNotEmpty) ...[
          _buildUnplacedNodesBanner(theme, unplacedNodes),
          const SizedBox(height: AppDimensions.spaceSm),
        ],

        // 2D Interactive Canvas Container
        AquaCard(
          padding: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            child: SizedBox(
              height: 340,
              width: double.infinity,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final canvasWidth = constraints.maxWidth;
                  final canvasHeight = constraints.maxHeight;

                  return Stack(
                    children: [
                      // Field Custom Painter (perimeter, grid, zones)
                      CustomPaint(
                        size: Size(canvasWidth, canvasHeight),
                        painter: _FieldCanvasPainter(
                          showGridLines: state.showGridLines,
                          widthMeters: state.fieldWidthMeters,
                          heightMeters: state.fieldHeightMeters,
                          isDark: theme.brightness == Brightness.dark,
                          nodes: widget.nodes,
                        ),
                      ),

                      // Placed Node Markers
                      ...widget.nodes.map((node) {
                        final norm = _notifier.getNormalizedPosition(
                          node,
                          allNodes: widget.nodes,
                        );
                        if (norm == null) return const SizedBox.shrink();

                        final posX = norm.x * canvasWidth;
                        final posY = norm.y * canvasHeight;
                        final isSelected = node.id == state.selectedNodeId;

                        return Positioned(
                          left: (posX - 40).clamp(4.0, canvasWidth - 100),
                          top: (posY - 35).clamp(4.0, canvasHeight - 45),
                          child: NodeMarkerWidget(
                            node: node,
                            isSelected: isSelected,
                            onTap: () {
                              _notifier.selectNode(node.id);
                              widget.onNodeSelected?.call(node);
                            },
                          ),
                        );
                      }),

                      // Dynamic Zone Count Legend (Top Right)
                      if (widget.nodes.isNotEmpty)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${widget.nodes.map((n) => n.assignedZoneId).where((id) => id != null && id.isNotEmpty).toSet().length} Zones • ${widget.nodes.length} Nodes',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                      // Origin & Scale Legend
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '(0,0) Origin • ${state.fieldWidthMeters.toInt()}m × ${state.fieldHeightMeters.toInt()}m',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),

        // Selected Node Quick Inspector Card
        if (selectedNode != null) ...[
          const SizedBox(height: AppDimensions.spaceMd),
          _buildSelectedNodeInspector(theme, selectedNode),
        ],
      ],
    );
  }

  Widget _buildControlsBar(ThemeData theme, SpatialFieldStateData state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.map_outlined, size: 20, color: AppColors.primary),
            const SizedBox(width: AppDimensions.spaceSm),
            Text(
              'Spatial Field Layout',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(
                state.showGridLines ? Icons.grid_on : Icons.grid_off,
                size: 20,
              ),
              tooltip: state.showGridLines ? 'Hide Grid' : 'Show Grid',
              onPressed: _notifier.toggleGridLines,
            ),
            IconButton(
              icon: const Icon(Icons.center_focus_strong, size: 20),
              tooltip: 'Reset Selection',
              onPressed: () => _notifier.selectNode(null),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUnplacedNodesBanner(
    ThemeData theme,
    List<Esp32Node> unplaced,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceSm),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, size: 16, color: AppColors.warning),
              const SizedBox(width: 6),
              Text(
                '${unplaced.length} Unplaced Nodes (Awaiting Coordinates):',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            children: unplaced.map((node) {
              return ActionChip(
                label: Text(node.displayName, style: const TextStyle(fontSize: 11)),
                onPressed: () {
                  _notifier.selectNode(node.id);
                  widget.onNodeSelected?.call(node);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedNodeInspector(ThemeData theme, Esp32Node node) {
    final coords = node.coordinates;
    final interval = node.transmissionConfig;

    return AquaCard(
      borderColor: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      node.displayName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'MAC: ${node.macAddress} • ${node.isOnline ? 'Online' : 'Offline'}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (widget.onConfigureInterval != null)
                IconButton(
                  icon: const Icon(Icons.tune, color: AppColors.primary),
                  tooltip: 'Configure Interval',
                  onPressed: () => widget.onConfigureInterval?.call(node),
                ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceSm),

          // Coordinates & Transmission summary
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              if (coords?.hasLocalCoordinates == true)
                Text(
                  'Local: X ${coords!.localX!.toStringAsFixed(1)}m, Y ${coords.localY!.toStringAsFixed(1)}m',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (coords?.hasGeoCoordinates == true)
                Text(
                  'GPS: ${coords!.latitude!.toStringAsFixed(4)}, ${coords.longitude!.toStringAsFixed(4)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    interval.isAdaptive ? Icons.bolt : Icons.timer,
                    size: 14,
                    color: interval.isAdaptive ? AppColors.accent : AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Interval: ${interval.intervalSeconds}s ${interval.isAdaptive ? '(Adaptive)' : '(Fixed)'}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: interval.isAdaptive ? AppColors.accent : null,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (interval.isAdaptive && interval.adaptiveReason != null) ...[
            const SizedBox(height: 4),
            Text(
              'Reason: ${interval.adaptiveReason}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.accent,
                fontStyle: FontStyle.italic,
                fontSize: 11,
              ),
            ),
          ],
          const SizedBox(height: AppDimensions.spaceSm),

          // Sensor metrics
          Row(
            children: [
              Expanded(
                child: SensorMetricTile(
                  label: 'Moisture',
                  value: node.soilMoisturePercent != null
                      ? '${node.soilMoisturePercent!.toStringAsFixed(1)}%'
                      : 'N/A',
                  icon: Icons.water_drop,
                  color: AppColors.primary,
                ),
              ),
              Expanded(
                child: SensorMetricTile(
                  label: 'Water Depth',
                  value: node.waterLevelCm != null
                      ? '${node.waterLevelCm!.toStringAsFixed(1)} cm'
                      : 'N/A',
                  icon: Icons.waves,
                  color: AppColors.accent,
                ),
              ),
              Expanded(
                child: SensorMetricTile(
                  label: 'Battery',
                  value: node.batteryPercent != null
                      ? '${node.batteryPercent}%'
                      : 'N/A',
                  icon: Icons.battery_charging_full,
                  color: (node.batteryPercent ?? 100) < 20
                      ? AppColors.alertWarning
                      : AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FieldCanvasPainter extends CustomPainter {
  final bool showGridLines;
  final double widthMeters;
  final double heightMeters;
  final bool isDark;
  final List<Esp32Node> nodes;

  _FieldCanvasPainter({
    required this.showGridLines,
    required this.widthMeters,
    required this.heightMeters,
    required this.isDark,
    this.nodes = const [],
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Field Background
    final bgPaint = Paint()
      ..color = isDark
          ? const Color(0xFF14241B)
          : const Color(0xFFEAF5EE);
    canvas.drawRect(Offset.zero & size, bgPaint);

    // 2. Grid lines
    if (showGridLines) {
      final gridPaint = Paint()
        ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.07)
        ..strokeWidth = 1.0;

      const gridDivisions = 4;
      for (int i = 1; i < gridDivisions; i++) {
        final x = (size.width / gridDivisions) * i;
        final y = (size.height / gridDivisions) * i;
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
        canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
      }
    }

    // 3. Dynamic Field Zone Partitions
    final partitionPaint = Paint()
      ..color = (isDark ? AppColors.primary : AppColors.primaryDark)
          .withValues(alpha: 0.20)
      ..strokeWidth = 1.5;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Group placed nodes by assigned zone
    final zoneNodeMap = <String, List<Esp32Node>>{};
    for (final node in nodes) {
      final zoneId = node.assignedZoneId;
      if (zoneId != null && zoneId.isNotEmpty) {
        zoneNodeMap.putIfAbsent(zoneId, () => []).add(node);
      }
    }

    // If 4 zones with Q-based codes, render subtle quadrant partition guides
    if (zoneNodeMap.length == 4 && zoneNodeMap.keys.any((k) => k.toUpperCase().contains('Q'))) {
      canvas.drawLine(Offset(centerX, 0), Offset(centerX, size.height), partitionPaint);
      canvas.drawLine(Offset(0, centerY), Offset(size.width, centerY), partitionPaint);
    }

    // 4. Dynamic Zone Watermark Labels based on centroid of placed nodes
    for (final entry in zoneNodeMap.entries) {
      final zoneId = entry.key;
      final zoneNodes = entry.value;

      double sumX = 0;
      double sumY = 0;
      int count = 0;

      for (final n in zoneNodes) {
        final coords = n.coordinates;
        if (coords != null && coords.hasLocalCoordinates) {
          sumX += (coords.localX! / widthMeters).clamp(0.0, 1.0);
          sumY += (coords.localY! / heightMeters).clamp(0.0, 1.0);
          count++;
        }
      }

      if (count > 0) {
        final avgNormX = sumX / count;
        final avgNormY = sumY / count;
        final labelX = (avgNormX * size.width - 25).clamp(8.0, size.width - 85);
        final labelY = (avgNormY * size.height - 25).clamp(8.0, size.height - 20);
        _drawZoneLabel(canvas, zoneId, labelX, labelY);
      }
    }

    // 5. Perimeter Border
    final borderPaint = Paint()
      ..color = (isDark ? AppColors.primary : AppColors.primaryDark)
          .withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRect(Offset.zero & size, borderPaint);
  }

  void _drawZoneLabel(Canvas canvas, String label, double x, double y) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.25),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(covariant _FieldCanvasPainter oldDelegate) {
    return oldDelegate.showGridLines != showGridLines ||
        oldDelegate.widthMeters != widthMeters ||
        oldDelegate.heightMeters != heightMeters ||
        oldDelegate.isDark != isDark ||
        oldDelegate.nodes.length != nodes.length;
  }
}

