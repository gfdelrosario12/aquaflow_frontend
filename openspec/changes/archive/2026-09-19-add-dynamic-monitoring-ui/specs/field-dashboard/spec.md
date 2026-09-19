## ADDED Requirements

### Requirement: Dynamic zone count header and contrast breakdown
The system SHALL render the dashboard field condition header and zone contrast summary dynamically based on the actual number of configured zones and active reporting nodes, displaying live counts, configured zone identifiers, and adaptive layout rows without hardcoding quadrant labels or fixed Q1–Q4 badges.

#### Scenario: Rendering dashboard zone breakdown for variable zone count
- **WHEN** the user views the Home/Dashboard screen for a field configured with 6 monitoring zones
- **THEN** the header displays "6 Zones Active" and the breakdown card renders all 6 configured zones with individual moisture bars, status chips, and contrast indicators.

#### Scenario: Empty monitoring zones state on dashboard
- **WHEN** a newly created field contains zero configured monitoring zones
- **THEN** the dashboard renders an empty-state card guiding the operator to provision or assign monitoring zones rather than displaying missing quadrant errors.

