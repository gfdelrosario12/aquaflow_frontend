## Context

The AquaSense field monitoring system tracks telemetry from four independent monitoring quadrants: Q1 (North-East), Q2 (North-West), Q3 (South-East), and Q4 (South-West). To help farmers evaluate localized field condition variations, we need a dedicated zone analysis view providing trend analysis (determining whether a zone is becoming wetter or drier), historical telemetry visualization across multiple timeframes, sensor hardware health diagnostics, and clear redirection to centralized irrigation controls.

For background context and business drivers, see `proposal.md`.

## Goals / Non-Goals

**Goals:**
- Provide a dedicated, comprehensive `ZoneAnalysisScreen` for inspecting Q1, Q2, Q3, and Q4 telemetry.
- Compute dynamic trend direction ("Wetter", "Drier", "Stable") and rate of change (cm/h) based on historical water level telemetry.
- Support interactive multi-timeframe historical trend visualization (e.g., 24-hour vs 7-day trend windows).
- Enforce strict read-only boundaries: prohibit any zone-level pump or valve triggers, providing clear redirection to centralized field irrigation.
- Support robust UI states: loading, empty, stale telemetry, offline sensor node, and error states.

**Non-Goals:**
- Implementing production LoRaWAN network server protocols or live REST backend endpoints.
- Implementing zone-level pump controls (zone-level irrigation controls do not exist in AquaSense architecture).

## Decisions

### Decision 1: Trend Direction and Rate Computation
We will add domain extension/helper logic (`ZoneTrendAnalysis`) to evaluate `waterLevelHistory`:
- Compares earliest and latest telemetry points to determine delta ($\Delta \text{water\_level}$).
- Classifies trend state: `wetter` ($\Delta > 0.2\text{ cm}$), `drier` ($\Delta < -0.2\text{ cm}$), or `stable` ($|\Delta| \le 0.2\text{ cm}$).
- Computes estimated rate of change in cm/h for display on trend summary cards.

*Alternative Considered*: Hardcoded trend strings in mock data.  
*Rationale*: Computing trend dynamically from history array validates business logic, allows testing, and ensures seamless transition when real backend time-series data is wired up.

### Decision 2: Dedicated `ZoneAnalysisScreen` and Navigation Integration
We will implement a dedicated screen `ZoneAnalysisScreen` located in `lib/features/zones/presentation/zone_analysis_screen.dart`:
- Accessible from both the Field Monitoring screen (`FieldScreen`) and Dashboard zone cards (`HomeScreen`).
- Displays zone header, status badges, real-time metric tiles (Moisture, Depth, Temp, Humidity), trend analysis card, interactive multi-timeframe chart, sensor diagnostic panel (RSSI, SNR, Battery, Hardware, Firmware), and centralized irrigation redirection notice.

*Alternative Considered*: Extending `ZoneDetailBottomSheet` only.  
*Rationale*: A dedicated screen provides ample canvas for multi-timeframe chart filters, detailed diagnostic lists, and trend cards without sheet scrolling or height constraints, while `ZoneDetailBottomSheet` can navigate to the full analysis screen for deeper investigation.

### Decision 3: Multi-Timeframe Telemetry History Support
We will update `MonitoringZone` or repository data source to support multi-timeframe telemetry history (24h and 7d data points):
- `waterLevelHistory24h`: 24 hourly readings.
- `waterLevelHistory7d`: 7 daily average readings.
- `SimulatedTelemetryChart` will render data points based on the active timeframe selector chip (`24h` / `7d`).

### Decision 4: Read-Only Centralized Irrigation Redirection Banner
To enforce the strict prohibition of zone-level controls, `ZoneAnalysisScreen` will feature a high-visibility guidance banner:
- Reaffirms that Q1–Q4 are read-only telemetry points.
- Explains that irrigation is managed centrally for the entire field.
- Provides an explicit "Go to Centralized Controls" button that navigates directly to the `ControlScreen`.

## Risks / Trade-offs

- **[Risk] Mock telemetry data structure may shift when real API is integrated.**  
  → *Mitigation*: Abstract telemetry retrieval behind `ZoneRepository` and `MonitoringZone` model methods so UI code remains decoupled from data sources.
- **[Risk] Users might misinterpret quadrant trends as actionable for individual zones.**  
  → *Mitigation*: Emphasize field-level AWD context in the redirection banner and exclude any zone-specific action buttons.

