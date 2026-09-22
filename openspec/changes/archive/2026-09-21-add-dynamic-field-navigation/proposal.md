## Why

Clicking monitoring zone/quadrant cards on the Home Dashboard currently navigates to an isolated Zone Analysis screen. To improve field overview workflow, tapping any dynamic zone/quadrant card on the Home tab should route the user directly to the primary Field tab while maintaining support for dynamic zone counts (arbitrary N-zone field setups) rather than assuming a fixed set of four quadrants (Q1–Q4).

## What Changes

- Modify `ZoneContrastSummaryCard` on the Home tab so tapping any zone item invokes `onNavigateToField` to navigate directly to the main Field tab.
- Reinforce dynamic zone/quadrant support across Home and Field tabs, rendering dynamic zone counts (1, 2, 4, 6, 8+ zones) without hardcoding fixed Q1–Q4 quadrant assumptions.
- Update `field-dashboard` and `monitoring-zones` specifications to mandate direct Field tab navigation from Home dashboard zone cards.

## Capabilities

### Modified Capabilities

- `field-dashboard`: Update monitoring zones summary requirement so tapping zone breakdown cards navigates directly to the Field tab.
- `monitoring-zones`: Clarify that home dashboard zone interaction routes to the main Field tab while preserving dynamic zone counts.

## Impact

- `lib/features/home/presentation/widgets/zone_contrast_summary_card.dart`
- `lib/features/home/presentation/home_screen.dart`
- Related widget tests in `test/`
