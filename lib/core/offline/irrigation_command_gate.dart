import 'offline_models.dart';
import 'connectivity_service.dart';

class IrrigationCommandDecision {
  final bool allowed;
  final String message;

  const IrrigationCommandDecision({
    required this.allowed,
    required this.message,
  });
}

class IrrigationCommandGate {
  final ConnectivityNotifier connectivity;

  const IrrigationCommandGate(this.connectivity);

  IrrigationCommandDecision check({
    required bool authenticated,
    required bool irrigationAuthorized,
    required bool controllerConfirmed,
    required String target,
    required CacheConfirmation confirmation,
  }) {
    if (target != 'ENTIRE FIELD') {
      return const IrrigationCommandDecision(
        allowed: false,
        message: 'Irrigation commands apply only to ENTIRE FIELD.',
      );
    }
    if (!authenticated) {
      return const IrrigationCommandDecision(
        allowed: false,
        message: 'Sign in is required before irrigation commands.',
      );
    }
    if (!irrigationAuthorized) {
      return const IrrigationCommandDecision(
        allowed: false,
        message: 'Unauthorized: irrigation control permission is required.',
      );
    }
    if (!connectivity.canReachBackend || !controllerConfirmed) {
      return const IrrigationCommandDecision(
        allowed: false,
        message:
            'Live backend and controller confirmation are required before irrigation commands.',
      );
    }
    if (confirmation != CacheConfirmation.live) {
      return const IrrigationCommandDecision(
        allowed: false,
        message:
            'Cached or stale controller state cannot authorize irrigation commands.',
      );
    }
    return const IrrigationCommandDecision(
      allowed: true,
      message: 'Centralized field command may be submitted.',
    );
  }
}
