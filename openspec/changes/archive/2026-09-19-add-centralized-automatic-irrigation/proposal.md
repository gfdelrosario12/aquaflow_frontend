## Why

AquaSense currently supports manual centralized irrigation triggers and dynamic AWD analysis, but requires human operators to continuously monitor recommendations and initiate pumping. To realize true water savings and operational efficiency, the system needs an autonomous, field-level automatic irrigation control engine that consumes multi-node AWD telemetry, enforces strict agronomic and physical safety interlocks, commands the central irrigation controller over LoRaWAN/messaging gateways, and maintains an auditable execution history distinguishing automated triggers from manual overrides.

## What Changes

- **Automatic Irrigation Supervisor State Machine**: Establish field-level automatic irrigation states (`disabled`, `standby`, `evaluating`, `pendingAck`, `irrigating`, `cooldown`, `faultLocked`).
- **Autonomous Decision & Eligibility Evaluation**: Implement rule-based automated trigger eligibility evaluating AWD reflood recommendation, telemetry confidence rating (`High` or `Moderate`), data freshness, and absence of zone moisture disparity.
- **Safety Interlocks & Inhibition Conditions**: Enforce critical pre-flight safety checks (max duration caps, minimum inter-irrigation cooldown period, weather/rain delay inhibition, controller online health, flow/pressure sensor bounds) before triggering pump activation.
- **Command Lifecycle & Robust Acknowledgement**: Define end-to-end command orchestration between Backend, Message Broker (MQTT/LoRaWAN), and Central Irrigation Controller with correlation IDs, timeout handling, retry backoff, and fail-safe hardware shutdown on communication loss.
- **Distinguishable Actor Auditing**: Track all irrigation activations with explicit actor attribution (`system/auto-awd` vs `user/<userId>`) and capture rationales, confidence scores, and pre-run telemetry snapshots in the audit log.
- **Frontend Automatic Mode Configuration & Monitoring**: Provide intuitive UI toggles for Auto-AWD mode, safety parameter configuration (max duration, target water depth, quiet hours), live automation status banners, and safety lockout override controls.

## Capabilities

### Modified Capabilities
- `centralized-irrigation`: Define automatic irrigation control state machine, autonomous trigger eligibility, pre-flight safety constraints, command lifecycle/acknowledgements, fail-safe lockouts, and system-attributed execution logs.
- `awd-analytics`: Extend analytics outputs to include automated irrigation eligibility flags, safety inhibition codes (e.g. disparity conflict, low confidence), and target fill volume estimates.
- `api-integration`: Define backend API endpoints and WebSocket/real-time events for automation mode toggling, automated trigger dispatch events, and audit log actor attribution.

## Impact

- **Frontend Core & Models**: Updates to `CentralizedIrrigation`, `IrrigationCommand`, and addition of `AutoIrrigationConfig`, `AutoIrrigationState`, and `IrrigationExecutionAuditLog`.
- **UI Components**: Enhancements to `ControlScreen`, `FieldConditionHeaderCard`, and `AwdAnalyticsScreen` to render automatic status indicators, lockout warnings, and configuration controls.
- **Backend & Protocol Contracts**: Explicit request/response schemas for `/api/irrigation/auto-config`, `/api/irrigation/history`, and asynchronous command execution events over LoRaWAN/MQTT downlinks.

