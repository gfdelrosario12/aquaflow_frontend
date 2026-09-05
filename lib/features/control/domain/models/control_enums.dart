/// Controller connectivity and hardware operational state
enum CentralControllerState { online, offline, emergencyStop, maintenance }

/// Main irrigation pump operational status
enum PumpStatus { off, pumping, fault }

/// Central distribution valve status
enum MainValveStatus { closed, open, transitioning }

/// Current field irrigation state
enum IrrigationState { idle, irrigating, commandPending, error }

/// Types of control commands supported by the centralized controller
enum CommandType { startIrrigation, stopIrrigation }

/// Execution outcome of a control command across the pipeline
enum CommandOutcome { acknowledged, inProgress, completed, timedOut, rejected, failed }

/// User authorization roles for control operations
enum ControlUserRole { admin, operator, viewer }

