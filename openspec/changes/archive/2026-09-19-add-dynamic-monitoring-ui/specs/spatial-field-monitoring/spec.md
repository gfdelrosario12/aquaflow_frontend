## ADDED Requirements

### Requirement: Dynamic spatial zone boundary and label rendering
The system SHALL dynamically render spatial zone labels, partitions, and field boundaries derived from backend field metadata and active node positions, without hardcoding fixed 4-quadrant corner labels or static split lines.

#### Scenario: Visualizing field with arbitrary zone distribution
- **WHEN** the user switches to the 2D spatial view for a field with dynamic node placements
- **THEN** the canvas renders relative node positions and dynamic zone tags based on configured zone assignments without drawing hardcoded "Q1 (North-East)" through "Q4 (South-East)" corner overlays.

#### Scenario: Visualizing single-zone or multi-zone fields
- **WHEN** a field has 1, 2, 6, or 8 nodes distributed across coordinates
- **THEN** the spatial canvas bounds scale dynamically to encompass all nodes and display their configured names and telemetry states.

