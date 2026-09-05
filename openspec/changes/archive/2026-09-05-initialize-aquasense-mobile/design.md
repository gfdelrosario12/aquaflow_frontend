## Context

See `proposal.md` for overall project motivation and scope. AquaSense is a smart water management and agricultural monitoring mobile app. The application is built using Flutter and targeted primarily at Android devices with screen widths between 360px and 430px.

## Goals / Non-Goals

**Goals:**
- Establish a clean, feature-first Flutter codebase architecture (`lib/core` and `lib/features`).
- Implement an adaptive shell navigation for 5 key views: Home, Field, Analytics, Control, and Settings.
- Build domain models and mock data repositories isolating independent monitoring zones (Q1–Q4) from field-wide centralized irrigation system controls.
- Create dark-first visual design tokens (colors, typography, cards, badges) with high visual appeal.
- Implement reusable UI states (loading, error, empty, responsive containers) to prepare for REST API integrations.

**Non-Goals:**
- Production authentication or security hardening.
- Live backend connection, REST API endpoints, LoRaWAN, MQTT, or real-time WebSockets.
- AWD (Alternate Wetting and Drying) algorithms or automated hardware triggers.
- Zone-level irrigation controls (irrigation is strictly field-wide).
- Actual physical pump/valve control or push notification integration.

## Decisions

### Decision 1: Feature-First Clean Architecture
- **Choice**: Organize code by feature (`lib/features/{home,field,analytics,control,settings,zones,irrigation}`) with inner layers (`data`, `domain`, `presentation`), complemented by `lib/core` for shared utilities, themes, and UI components.
- **Rationale**: Keeps code modular and allows subsequent feature additions without risk of breaking existing screens or models.
- **Alternatives Considered**: Layer-first architecture (`lib/models`, `lib/views`, `lib/controllers`). Rejected due to scaling friction as feature set grows.

### Decision 2: Declarative Navigation Shell & State Management
- **Choice**: Use a indexed navigation shell widget (`AppShell`) wrapping a bottom navigation bar for high-performance tab switching, coupled with state management abstractions (`Bloc` / `Cubit` pattern or `StatefulWidget` controller wrappers).
- **Rationale**: Provides smooth page transitions while keeping state persistent across bottom navigation tab switches.
- **Alternatives Considered**: Material `Navigator.push` per tab switch. Rejected because tab history and view state would be recreated on each navigation event.

### Decision 3: Domain Isolation (Q1–Q4 Monitoring vs. Centralized Irrigation)
- **Choice**: Represent Q1, Q2, Q3, and Q4 strictly as `MonitoringZone` domain entities containing soil moisture, water level, and sensor battery metrics. Centralized irrigation is modeled separately as a single `CentralizedIrrigationSystem` entity representing field-wide main pumps, valves, and water flow rate.
- **Rationale**: Strictly prevents confusion between monitoring metrics and irrigation control capabilities, fulfilling core domain constraints.
- **Alternatives Considered**: Unified Zone model containing optional irrigation switches. Rejected because physical irrigation serves the entire field as one system, not individual quadrants.

### Decision 4: Repository & Mock Data Source Abstraction
- **Choice**: Define abstract repository interfaces (e.g., `ZoneRepository`, `IrrigationRepository`) backed by `MockZoneDataSource` and `MockIrrigationDataSource` implementations with simulated network delays.
- **Rationale**: Enables building rich UI states and domain logic now, while making future REST API integration trivial by swapping mock data sources with HTTP data sources.
- **Alternatives Considered**: Direct inline mock data in UI widgets. Rejected due to tight coupling and refactoring overhead later.

## Risks / Trade-offs

- **[Risk] Responsive layout breakdown on smaller devices (< 360px) or extra wide screens** → **Mitigation**: Wrap views in `SingleChildScrollView` or `LayoutBuilder`-based responsive containers (`ResponsiveLayout`) with strict padding constraints for 360–430px screens.
- **[Risk] Confusion over zone-level controls in future development** → **Mitigation**: Explicitly omit control methods from `MonitoringZone` models and `ZoneRepository` interfaces.

## Migration Plan

1. Scaffold new directory structure in `lib/core/` and `lib/features/`.
2. Implement theme, design tokens, and shared feedback widgets.
3. Define domain models, repository contracts, and mock data sources.
4. Implement application shell navigation (`AppShell`) and connect five feature pages (Home, Field, Analytics, Control, Settings).
5. Verify application compilation and mobile responsiveness.
