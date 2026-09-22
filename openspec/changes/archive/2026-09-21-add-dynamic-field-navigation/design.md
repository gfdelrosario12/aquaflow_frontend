## Context

Currently `ZoneContrastSummaryCard` on the Home screen pushes a `ZoneAnalysisScreen` modal when a zone card is tapped. The user requires tapping any quadrant/zone card on the Home tab to navigate directly to the primary Field tab. In addition, the system architecture supports arbitrary dynamic zone counts (1, 2, 4, 6, 8+ zones) rather than assuming a hardcoded four-quadrant (Q1–Q4) setup.

## Goals / Non-Goals

**Goals:**
- Update `ZoneContrastSummaryCard` `onTap` callback to trigger `onNavigateToField` (or fallback navigation to Field tab) when a zone item is tapped on the Home screen.
- Maintain dynamic grid responsiveness across variable zone counts (1 to N zones).
- Ensure existing unit and widget tests pass.

**Non-Goals:**
- Disabling the Zone Analysis screen when accessed directly from the Field tab.
- Modifying backend zone telemetry contracts.

## Decisions

### 1. Direct Field Navigation Callback in ZoneContrastSummaryCard
- **Decision:** If `onNavigateToField` is provided, invoking any zone item tap calls `onNavigateToField!()`. If `onNavigateToField` is null, fall back to pushing `ZoneAnalysisScreen`.
- **Rationale:** Preserves fallback behavior while ensuring Home tab users transition directly to the Field tab as requested.

### 2. Dynamic Zone Layout Preservation
- **Decision:** Retain dynamic `GridView.builder` child aspect ratio calculation based on `zones.length` and viewport width.
- **Rationale:** Ensures UI scales seamlessly whether 1, 4, 6, or 8+ nodes are deployed.

## Risks / Trade-offs

- **[Risk] Widget tests expecting ZoneAnalysisScreen from Home tab** → **Mitigation:** Update Home tab widget tests to verify `onNavigateToField` callback is triggered when tapping zone cards.
