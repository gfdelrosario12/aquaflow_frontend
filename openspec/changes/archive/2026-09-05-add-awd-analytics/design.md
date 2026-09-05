## Context

Alternate Wetting and Drying (AWD) is a water-management practice for lowland rice fields where soil is allowed to dry periodically before reflooding, saving up to 30% of irrigation water without reducing yield. In AquaSense, field telemetry is collected via four independent telemetry monitoring zones (Q1, Q2, Q3, Q4). To evaluate AWD conditions across the field, we need a field-level AWD analytics engine that aggregates Q1–Q4 measurements, computes drying and wetting rate trends, applies configurable AWD decision rules, and generates a clear field-level irrigation recommendation.

See `proposal.md` for background motivation and business requirements.

## Goals / Non-Goals

**Goals:**
- Provide domain models (`AwdThresholdConfig`, `AwdAnalyticsSummary`, `AwdRecommendation`) for field-level AWD evaluation.
- Implement an `AwdRuleEngine` domain service that aggregates Q1–Q4 telemetry and applies configurable threshold rules.
- Support configurable threshold parameters (safe drying depth limit, reflood trigger depth, target flood depth) without inventing hardcoded scientific constants.
- Provide a dedicated `AwdAnalyticsScreen` and summary cards detailing drying/wetting trends across Q1–Q4 and human-readable recommendation rationale.
- Direct recommendations exclusively to the single centralized irrigation system (`ControlScreen`).
- Support loading, insufficient data (<4 nodes reporting), stale telemetry, and gateway error states.

**Non-Goals:**
- Hardcoding unvalidated, fixed scientific thresholds.
- Generating zone-level pump or valve activation commands (zone-level irrigation controls do not exist in AquaSense architecture).

## Decisions

### Decision 1: Domain Models & Configurable Threshold Rules Engine
We will create structured domain models under `lib/features/awd/domain/`:
- `AwdThresholdConfig`: Holds configurable parameters:
  - `safeDryThresholdCm` (default `-15.0 cm` below soil surface)
  - `refloodTriggerCm` (default `-15.0 cm`)
  - `targetFloodDepthCm` (default `+5.0 cm`)
  - `criticalDrynessThresholdCm` (default `-20.0 cm`)
- `AwdRecommendation`: Contains field decision (`irrigate`, `doNotIrrigate`, `monitor`), urgency level, and detailed rationale string explaining why the recommendation was generated.
- `AwdRuleEngine`: Pure domain class evaluating `List<MonitoringZone>` against `AwdThresholdConfig`:
  - Computes field average depth, minimum depth across zones, maximum depth across zones, and drying/wetting rates ($\text{cm/day}$).
  - Evaluates how many zones are below `refloodTriggerCm`.
  - Generates transparent rationale (e.g. "Irrigation Recommended: 2 of 4 monitoring zones (Q2, Q4) have fallen below the configured -15.0 cm reflood threshold.").

*Alternative Considered*: Static text strings in mock repositories.  
*Rationale*: A pure domain rules engine allows unit testing, supports dynamic configuration tweaks, and prepares the frontend for future live backend rule execution.

### Decision 2: `AwdRepository` and Data Abstraction
We will create `AwdRepository` in `lib/features/awd/data/repositories/awd_repository.dart`:
- `fetchAwdAnalytics({AwdThresholdConfig? config, AwdMockState mockState})`.
- Implemented by `AwdRepositoryImpl` which retrieves `MonitoringZone` telemetry from `ZoneRepository` and executes `AwdRuleEngine` to produce `AwdAnalyticsSummary`.

### Decision 3: Presentation UI & Screen Structure
We will create `AwdAnalyticsScreen` in `lib/features/awd/presentation/awd_analytics_screen.dart`:
1. **Header Overview Card**: Aggregated field water status badge (Safe Dry, Reflood Needed, Flooded, Critical), average depth, and moisture range.
2. **Irrigation Recommendation & Rationale Card**: Prominent recommendation statement with explicit rationale bullet points and a shortcut button to `ControlScreen`.
3. **Configurable Threshold Inspector & Editor**: Allows inspecting active AWD threshold parameters and adjusting configuration.
4. **Quad-Zone Drying & Wetting Rate Comparison**: Table/card breakdown comparing drying/wetting rates ($\text{cm/day}$) across Q1, Q2, Q3, and Q4.
5. **Historical AWD Level Chart**: Time-series chart rendering field average vs. configured safe dry threshold line.

### Decision 4: Read-Only Guardrails & Centralized Scope
To enforce non-controllable telemetry scope:
- The recommendation applies strictly to the single centralized irrigation system serving the entire field.
- No zone-specific activation buttons exist on the AWD screen.
- A clear notice directs all watering actions to `ControlScreen`.

## Risks / Trade-offs

- **[Risk] Fewer than 4 nodes reporting could skew field averages.**  
  → *Mitigation*: Implement an `insufficient-data` state if fewer than 4 nodes return valid telemetry, warning the user that field-wide AWD analysis requires complete quadrant coverage.
- **[Risk] Farmers might mistake default threshold values for scientific recommendations.**  
  → *Mitigation*: Add explicit UI labels indicating thresholds are configurable project parameters that should be set according to local agricultural extension guidelines.

