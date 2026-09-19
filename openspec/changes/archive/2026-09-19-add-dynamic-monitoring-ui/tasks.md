## 1. Dynamic Monitoring Grid & Responsive Layouts

- [x] 1.1 Create `DynamicZoneGridVisualizer` (deprecating `QuadrantGridVisualizer`) that accepts arbitrary `List<MonitoringZone>` and calculates responsive column counts (1, 2, 3, or 4 columns) via `LayoutBuilder`
- [x] 1.2 Refactor zone monitoring cards with dynamic child aspect ratios, ellipsis overflow guards, and configuration-driven titles
- [x] 1.3 Update `FieldScreen` to replace `QuadrantGridVisualizer` with `DynamicZoneGridVisualizer` and add dynamic header counts (e.g. "Field Monitoring Zones (N Active)")
- [x] 1.4 Implement dedicated empty, loading, and error states when a field has zero configured monitoring zones

## 2. Spatial Canvas & Dynamic Zone Visualization

- [x] 2.1 Refactor `SpatialFieldCanvasVisualizer` to remove hardcoded corner labels (`Q1 (North-East)`, `Q2 (North-West)`, `Q3 (South-East)`, `Q4 (South-West)`)
- [x] 2.2 Implement dynamic zone partition and label positioning based on active node coordinates and assigned zone boundaries
- [x] 2.3 Add dynamic canvas legend rendering for active monitoring zones when coordinates are dense or overlap

## 3. Flexible AWD Rule Engine & Analytics UI

- [x] 3.1 Refactor `AwdRuleEngine` to evaluate water condition and recommendations dynamically when one or more active monitoring zones report telemetry, removing the hardcoded 4-zone requirement
- [x] 3.2 Update `AwdRuleEngine` insufficient data handling to trigger only when zero active zones report or required field quorum is missing
- [x] 3.3 Update `AwdAnalyticsScreen` and `AnalyticsScreen` to remove hardcoded "Q1–Q4" titles, displaying dynamic zone counts and configured zone names in trend charts and recommendation cards

## 4. Dashboard, Diagnostics & Navigation Cleanup

- [x] 4.1 Update `FieldConditionHeaderCard` to dynamically display active zone counts (e.g. "N/M Zones Active") instead of hardcoded "Q1–Q4 Active"
- [x] 4.2 Update `ZoneContrastSummaryCard` to render dynamic zone bars, labels, and count headers (e.g. "Monitoring Zones Breakdown (N Zones)")
- [x] 4.3 Update `DeviceDiagnosticsScreen` node tab headers and section titles to dynamically show node counts (e.g. "Sensor Nodes (N)") instead of "Nodes (Q1–Q4)"
- [x] 4.4 Update `ZoneAnalysisScreen` and `AlertsScreen` informational banners to reference field-wide monitoring zones generically without fixed Q1–Q4 references

## 5. Verification & Testing

- [x] 5.1 Update unit tests in `test/unit/` for `AwdRuleEngine` covering single-zone, dual-zone, 6-zone, and 8-zone field configurations
- [x] 5.2 Write widget tests verifying `DynamicZoneGridVisualizer` renders correctly across 1, 2, 4, 6, and 8 zone configurations without RenderFlex overflow
- [x] 5.3 Execute responsive layout validation test suite across 360px, 400px, 600px, 900px, and 1200px viewports
- [x] 5.4 Execute full test suite (`flutter test`) and static analysis (`dart analyze`) to ensure 100% test pass rate and zero errors

