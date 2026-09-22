## MODIFIED Requirements

### Requirement: Monitoring zones relative moisture summary
The system SHALL display telemetry summaries for all dynamically provisioned monitoring zones in the active field as read-only monitoring points, highlighting relative moisture contrasts across dynamic zone counts, and SHALL route the user directly to the primary Field tab upon tapping any zone breakdown item.

#### Scenario: Summarizing zone moisture contrasts
- **WHEN** the user views the monitoring zones section on the dashboard
- **THEN** all active field monitoring zones display soil moisture and water depth metrics, dynamically identifying which zones are wettest or driest without presenting any zone-level irrigation controls.

#### Scenario: Tapping a monitoring zone card on dashboard
- **WHEN** the user taps any monitoring zone card or summary item on the Home dashboard
- **THEN** the application routes the user directly to the Field tab to inspect comprehensive field monitoring telemetry.
