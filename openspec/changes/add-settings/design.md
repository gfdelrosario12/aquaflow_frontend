## Context

AquaSense currently has settings-related UI concerns mixed into a broad settings screen and global theme state, while account, preference persistence, and application information do not have a single feature boundary. The new feature must serve operators on mobile layouts, preserve the existing AquaSense design system, and avoid coupling preference management to monitoring telemetry or irrigation control behavior.

## Goals / Non-Goals

**Goals:**
- Define a modular settings feature with sections for account, notifications, units, appearance, language, application information, and system preferences.
- Support `System`, `Light`, and `Dark` appearance modes through a typed preference model and the existing theme mode notifier.
- Add a repository abstraction with local/mock persistence today and a replaceable synchronization boundary for future backend integration.
- Represent loading, saving, saved, and error states without losing the last successfully loaded settings.
- Keep preference updates scoped to application behavior and presentation; field telemetry and centralized irrigation remain separate features.

**Non-Goals:**
- Implementing backend synchronization, remote account mutation, or authentication redesign.
- Adding controls for individual monitoring zones or Q1-Q4 irrigation behavior.
- Moving centralized irrigation configuration into settings; field-level control remains owned by control/backend features.
- Introducing unrelated system administration, device diagnostics, or field operations workflows.

## Decisions

### 1. Typed settings aggregate with section-oriented UI

- **Decision**: Model settings as a typed aggregate containing account summary, notification preferences, measurement units, appearance mode, language, application metadata, and system preferences. Render each area as an independent section widget.
- **Rationale**: A typed aggregate keeps persistence and validation consistent while modular sections make the screen maintainable and allow future server fields without coupling UI components.
- **Alternative considered**: A map of string keys was rejected because it weakens validation and makes appearance/unit updates error-prone.

### 2. Repository boundary for local persistence and future sync

- **Decision**: Introduce a `SettingsRepository` interface with load and save operations, backed initially by a local/mock implementation. The interface may later gain synchronization methods without changing presentation consumers.
- **Rationale**: Settings are stored asynchronously and need explicit loading/error behavior; the abstraction keeps storage mechanics out of widgets and supports future backend integration.
- **Alternative considered**: Writing directly to widget/global state was rejected because it cannot reliably represent persistence failures or future remote reconciliation.

### 3. ChangeNotifier state with last-known-value retention

- **Decision**: Use a settings notifier/provider to expose settings, loading state, saving state, and error messages. Failed saves retain the last successfully loaded value and expose retryable feedback.
- **Rationale**: This matches the repository's existing ChangeNotifier patterns and avoids blanking usable preferences during transient storage errors.
- **Alternative considered**: Ephemeral widget-local state was rejected because theme and settings must remain consistent across screens and app startup.

### 4. Appearance integration through existing theme mode state

- **Decision**: Map the typed appearance preference to `ThemeMode.system`, `ThemeMode.light`, and `ThemeMode.dark`, updating the existing global theme notifier only after the preference state accepts the change.
- **Rationale**: This preserves the current design system and gives immediate visual feedback while keeping persistence as the source of durable preference state.
- **Alternative considered**: A second independent theme controller was rejected because it could diverge from the app shell's active theme.

### 5. Explicit scope guardrails

- **Decision**: Settings models and UI contain no quadrant irrigation controls, zone-specific thresholds, pump actions, or valve actions. Any centralized irrigation configuration is represented only as an informational link or delegated action to the field-level control feature.
- **Rationale**: This prevents preference screens from becoming an accidental second control plane for irrigation hardware.
- **Alternative considered**: Adding convenience zone controls was rejected because it conflicts with the centralized irrigation architecture.

## Risks / Trade-offs

- **[Risk: Local storage failures leave preferences unsaved]** -> **Mitigation**: Keep the last successful settings snapshot, show an error state with retry, and avoid reporting a change as persisted until save succeeds.
- **[Risk: Theme changes feel inconsistent during save latency]** -> **Mitigation**: Apply the validated appearance choice immediately while clearly distinguishing applied state from persistence completion.
- **[Risk: Future backend fields create conflicts with local edits]** -> **Mitigation**: Keep repository and model boundaries explicit so synchronization policy can be added without embedding network behavior in widgets.
- **[Risk: Settings scope expands into operational controls]** -> **Mitigation**: Test that no Q1-Q4 irrigation actions or zone-specific control labels are exposed by the settings feature.

## Migration Plan

1. Add settings models, repository, notifier, and modular section widgets alongside the existing settings screen.
2. Initialize the notifier from local/mock persistence during app startup or settings entry.
3. Route appearance changes through the existing theme mode notifier and preserve current defaults for users without stored settings.
4. Keep the existing control and monitoring features unchanged; provide only field-level informational navigation where appropriate.
5. Future backend synchronization can replace or decorate the repository implementation without changing the settings UI contract.

## Open Questions

- Which secure storage mechanism should be selected for account-sensitive preference fields when backend synchronization is introduced?
- Should notification preference categories eventually be shared with the alert-management feature's domain model, or remain a settings-owned preference projection?
