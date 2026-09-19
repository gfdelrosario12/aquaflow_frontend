## 1. Domain Models & Agronomic Configuration

- [x] 1.1 Create `CropGrowthStage` enum (`vegetative`, `reproductive`, `ripening`) with agronomic threshold presets in `lib/features/awd/domain/models/crop_growth_stage.dart`
- [x] 1.2 Create `AwdConfidence` model with confidence level enum (`high`, `medium`, `low`, `insufficient`), numerical score (0.0 to 1.0), and contributing factors in `lib/features/awd/domain/models/awd_confidence.dart`
- [x] 1.3 Extend `AwdThresholdConfig` to support crop stage selection, outlier tolerance bounds, freshness timeout, maximum allowed spread, and minimum quorum ratio
- [x] 1.4 Extend `AwdAnalyticsSummary` to incorporate `AwdConfidence`, `hasConflictingConditions`, `waterDepthSpreadCm`, and list of flagged outlier nodes

## 2. Core AWD Evaluation & Data Quality Engine

- [x] 2.1 Implement physical bounds validation and statistical outlier filtering (MAD for $N \ge 4$) in `AwdRuleEngine`
- [x] 2.2 Implement spatially weighted field water depth and moisture aggregation in `AwdRuleEngine` supporting arbitrary zone counts ($N \ge 1$)
- [x] 2.3 Implement the confidence and completeness scoring algorithm in `AwdRuleEngine` based on active ratio, telemetry age, and validity
- [x] 2.4 Implement zone disparity detection and conflicting condition alerts in `AwdRuleEngine` when water depth spread exceeds threshold
- [x] 2.5 Refactor recommendation rationale generation in `AwdRuleEngine` to detail confidence level, active reporting nodes, and disparity explanations

## 3. UI Integration & Visual Indicators

- [x] 3.1 Update `AwdAnalyticsScreen` to render the AWD confidence badge, data completeness chip, and active crop growth stage
- [x] 3.2 Add Conflicting Condition / High Disparity advisory card to `AwdAnalyticsScreen` when extreme moisture gradients are detected
- [x] 3.3 Update `FieldConditionHeaderCard` on `HomeScreen` to display the confidence rating chip alongside the field water condition
- [x] 3.4 Update `ZoneAnalysisScreen` and zone bottom sheets to display telemetry freshness and data reliability status (valid, stale, outlier)

## 4. Verification & Testing Suite

- [x] 4.1 Add unit tests for physical bounds and MAD outlier filtering in `test/unit/`
- [x] 4.2 Add unit tests for confidence scoring across complete, degraded, stale, and insufficient telemetry
- [x] 4.3 Add unit tests for conflicting condition detection and crop stage specific thresholds
- [x] 4.4 Add widget tests verifying confidence badges, disparity banners, and responsive layout across viewports
- [x] 4.5 Execute full test suite (`flutter test`) and static analysis (`dart analyze .`) to ensure 100% pass rate and zero errors

