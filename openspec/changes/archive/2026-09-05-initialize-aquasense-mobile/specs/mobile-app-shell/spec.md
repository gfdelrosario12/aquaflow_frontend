## Purpose

Provides the primary application shell and bottom navigation router for switching between Home, Field, Analytics, Control, and Settings screens.

## ADDED Requirements

### Requirement: Application bottom navigation shell
The application MUST display a primary navigation shell providing access to Home, Field, Analytics, Control, and Settings screens.

#### Scenario: Switching primary navigation tabs
- **WHEN** the user taps a navigation item in the bottom bar
- **THEN** the active view transitions seamlessly to the selected screen while maintaining navigation state.

### Requirement: Mobile viewport optimization
The application shell MUST render without clipping, overflow, or layout degradation on target Android viewports between 360px and 430px width.

#### Scenario: Rendering on standard mobile viewport widths
- **WHEN** the app runs on devices with screen widths from 360px to 430px
- **THEN** navigation items, headers, cards, and interactive targets adhere to touch guidelines (at least 48dp) and fit within screen boundaries.
