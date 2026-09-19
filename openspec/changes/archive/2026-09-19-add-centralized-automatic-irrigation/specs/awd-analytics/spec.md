## ADDED Requirements

### Requirement: Automated irrigation decision eligibility and safety inhibition evaluation
The AWD Analytics engine SHALL evaluate automated irrigation trigger eligibility, computing a binary decision flag (`isEligibleForAutoIrrigation`), an estimated irrigation runtime duration (in minutes) based on field water deficit and pump capacity, and explicit inhibition codes (`disparityConflict`, `lowConfidence`, `staleTelemetry`, `criticalOutliers`, `cropStageTerminalDrainage`) to protect the field against unintended autonomous pumping.

#### Scenario: Evaluating automated irrigation eligibility for optimal reflood
- **WHEN** field water depth reaches or drops below the reflood trigger threshold, telemetry confidence is High or Moderate, no conflicting zone spread is detected, and data is fresh
- **THEN** `isEligibleForAutoIrrigation` is set to `true`, inhibition codes are empty, and estimated runtime duration is calculated.

#### Scenario: Inhibiting automated irrigation due to high zone disparity
- **WHEN** one or more zones are below reflood threshold but other zones remain flooded above the maximum allowed spread
- **THEN** `isEligibleForAutoIrrigation` is set to `false`, inhibition codes include `disparityConflict`, and the recommendation rationale explicitly notes that automated irrigation is inhibited pending physical inspection.

#### Scenario: Inhibiting automated irrigation due to degraded or stale telemetry
- **WHEN** telemetry confidence is Low or Insufficient, or data age exceeds the freshness timeout
- **THEN** `isEligibleForAutoIrrigation` is set to `false`, inhibition codes include `lowConfidence` or `staleTelemetry`, and automated pumping is blocked.

#### Scenario: Calculating estimated run duration for automated reflood
- **WHEN** automated irrigation is eligible and target flood depth is configured to $+5.0\text{ cm}$
- **THEN** the system calculates runtime duration proportional to water deficit $(+5.0\text{ cm} - \text{averageDepth})$, bounded by the maximum safety ceiling duration (default 45 minutes).

