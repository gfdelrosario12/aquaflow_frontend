import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../core/api/api_errors.dart';
import '../../data/repositories/control_repository.dart';
import '../../domain/models/models.dart';

class CentralControlStateData {
  final CentralControlTelemetry? telemetry;
  final bool isLoading;
  final bool isCommandPending;
  final String? activeCommandId;
  final String? errorMessage;
  final ControlUserRole userRole;
  final bool authenticated;

  const CentralControlStateData({
    this.telemetry,
    this.isLoading = false,
    this.isCommandPending = false,
    this.activeCommandId,
    this.errorMessage,
    this.userRole = ControlUserRole.operator,
    this.authenticated = true,
  });

  bool get irrigationAuthorized => userRole != ControlUserRole.viewer;

  CentralControlStateData copyWith({
    CentralControlTelemetry? telemetry,
    bool? isLoading,
    bool? isCommandPending,
    String? activeCommandId,
    String? errorMessage,
    ControlUserRole? userRole,
    bool? authenticated,
    bool clearError = false,
  }) {
    return CentralControlStateData(
      telemetry: telemetry ?? this.telemetry,
      isLoading: isLoading ?? this.isLoading,
      isCommandPending: isCommandPending ?? this.isCommandPending,
      activeCommandId: activeCommandId ?? this.activeCommandId,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      userRole: userRole ?? this.userRole,
      authenticated: authenticated ?? this.authenticated,
    );
  }
}

class CentralControlNotifier extends ChangeNotifier {
  final ControlRepository _repository;
  CentralControlStateData _state;
  StreamSubscription<CentralControlTelemetry>? _telemetrySub;
  bool _isDisposed = false;

  CentralControlNotifier({
    ControlRepository? repository,
    ControlUserRole initialRole = ControlUserRole.operator,
    bool authenticated = true,
  })  : _repository = repository ?? MockControlRepository(),
        _state = CentralControlStateData(
          userRole: initialRole,
          authenticated: authenticated,
        ) {
    _init();
  }

  CentralControlStateData get state => _state;

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  void _init() {
    loadTelemetry();
    _telemetrySub = _repository.watchCentralTelemetry().listen((telemetry) {
      _state = _state.copyWith(telemetry: telemetry);
      notifyListeners();
    });
  }

  Future<void> loadTelemetry() async {
    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();
    try {
      final telemetry = await _repository.getCentralTelemetry();
      _state = _state.copyWith(
        telemetry: telemetry,
        isLoading: false,
      );
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage:
            'Failed to connect to central irrigation controller telemetry.',
      );
    }
    notifyListeners();
  }

  void setUserRole(ControlUserRole role) {
    _state = _state.copyWith(userRole: role);
    notifyListeners();
  }

  void setAuthenticated(bool authenticated) {
    _state = _state.copyWith(authenticated: authenticated);
    notifyListeners();
  }

  Future<ControlCommandResult> startIrrigation({
    required int durationMinutes,
    required String requestedBy,
    ControlUserRole? role,
  }) {
    return _dispatch(
      type: CommandType.startIrrigation,
      durationMinutes: durationMinutes,
      requestedBy: requestedBy,
      role: role,
    );
  }

  Future<ControlCommandResult> stopIrrigation({
    required String requestedBy,
    ControlUserRole? role,
  }) {
    return _dispatch(
      type: CommandType.stopIrrigation,
      durationMinutes: 0,
      requestedBy: requestedBy,
      role: role,
    );
  }

  Future<ControlCommandResult> _dispatch({
    required CommandType type,
    required int durationMinutes,
    required String requestedBy,
    ControlUserRole? role,
  }) async {
    final effectiveRole = role ?? _state.userRole;

    if (!_state.authenticated) {
      return _reject(
        type: type,
        message: 'Sign in is required before irrigation commands.',
      );
    }

    if (effectiveRole == ControlUserRole.viewer) {
      return _reject(
        type: type,
        message:
            'Unauthorized: Viewer role cannot initiate field irrigation controls.',
      );
    }

    if (_state.isCommandPending) {
      return ControlCommandResult(
        commandId: 'REJECTED-INFLIGHT',
        type: type,
        outcome: CommandOutcome.rejected,
        message:
            'A command is already pending execution. Concurrency lock active.',
        timestamp: DateTime.now(),
      );
    }

    final commandId = 'CMD-${DateTime.now().millisecondsSinceEpoch}';
    final command = ControlCommand(
      id: commandId,
      type: type,
      target: CentralControlTelemetry.fixedTarget,
      durationMinutes: durationMinutes,
      timestamp: DateTime.now(),
      requestedBy: requestedBy,
      userRole: effectiveRole,
    );

    _state = _state.copyWith(
      isCommandPending: true,
      activeCommandId: commandId,
      clearError: true,
    );
    notifyListeners();

    try {
      final result = await _repository.dispatchCommand(command);
      final updatedTelemetry = await _repository.getCentralTelemetry();
      _state = _state.copyWith(
        telemetry: updatedTelemetry,
        isCommandPending: false,
        activeCommandId: null,
        errorMessage: result.isSuccess ? null : result.message,
      );
      notifyListeners();
      return result;
    } on ApiException catch (error) {
      final errorResult = ControlCommandResult(
        commandId: commandId,
        type: type,
        outcome: _outcomeFor(error),
        message: _messageFor(error),
        timestamp: DateTime.now(),
      );
      _state = _state.copyWith(
        isCommandPending: false,
        activeCommandId: null,
        errorMessage: errorResult.message,
      );
      notifyListeners();
      return errorResult;
    } catch (_) {
      final errorResult = ControlCommandResult(
        commandId: commandId,
        type: type,
        outcome: CommandOutcome.failed,
        message:
            'Irrigation command failed. Re-check centralized field status before retrying.',
        timestamp: DateTime.now(),
      );
      _state = _state.copyWith(
        isCommandPending: false,
        activeCommandId: null,
        errorMessage: errorResult.message,
      );
      notifyListeners();
      return errorResult;
    }
  }

  ControlCommandResult _reject({
    required CommandType type,
    required String message,
  }) {
    final result = ControlCommandResult(
      commandId: 'REJECTED-SECURITY',
      type: type,
      outcome: CommandOutcome.rejected,
      message: message,
      timestamp: DateTime.now(),
    );
    _state = _state.copyWith(errorMessage: message);
    notifyListeners();
    return result;
  }

  CommandOutcome _outcomeFor(ApiException error) {
    switch (error.kind) {
      case ApiErrorKind.timeout:
        return CommandOutcome.timedOut;
      case ApiErrorKind.authentication:
      case ApiErrorKind.authorization:
        return CommandOutcome.rejected;
      default:
        return CommandOutcome.failed;
    }
  }

  String _messageFor(ApiException error) {
    switch (error.kind) {
      case ApiErrorKind.timeout:
        return 'Irrigation command timed out before controller acknowledgment. Status is unconfirmed.';
      case ApiErrorKind.authentication:
        return 'Sign in is required before irrigation commands.';
      case ApiErrorKind.authorization:
        return 'Unauthorized: you do not have irrigation control permission.';
      default:
        return 'Irrigation command failed. Re-check centralized field status before retrying.';
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _telemetrySub?.cancel();
    super.dispose();
  }
}
