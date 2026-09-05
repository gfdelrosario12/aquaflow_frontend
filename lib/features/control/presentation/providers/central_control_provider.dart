import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/repositories/control_repository.dart';
import '../../domain/models/models.dart';

class CentralControlStateData {
  final CentralControlTelemetry? telemetry;
  final bool isLoading;
  final bool isCommandPending;
  final String? activeCommandId;
  final String? errorMessage;
  final ControlUserRole userRole;

  const CentralControlStateData({
    this.telemetry,
    this.isLoading = false,
    this.isCommandPending = false,
    this.activeCommandId,
    this.errorMessage,
    this.userRole = ControlUserRole.operator,
  });

  CentralControlStateData copyWith({
    CentralControlTelemetry? telemetry,
    bool? isLoading,
    bool? isCommandPending,
    String? activeCommandId,
    String? errorMessage,
    ControlUserRole? userRole,
    bool clearError = false,
  }) {
    return CentralControlStateData(
      telemetry: telemetry ?? this.telemetry,
      isLoading: isLoading ?? this.isLoading,
      isCommandPending: isCommandPending ?? this.isCommandPending,
      activeCommandId: activeCommandId ?? this.activeCommandId,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      userRole: userRole ?? this.userRole,
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
  })  : _repository = repository ?? MockControlRepository(),
        _state = CentralControlStateData(userRole: initialRole) {
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
        errorMessage: 'Failed to connect to central irrigation controller telemetry: $e',
      );
    }
    notifyListeners();
  }

  void setUserRole(ControlUserRole role) {
    _state = _state.copyWith(userRole: role);
    notifyListeners();
  }

  Future<ControlCommandResult> startIrrigation({
    required int durationMinutes,
    required String requestedBy,
    ControlUserRole? role,
  }) async {
    final effectiveRole = role ?? _state.userRole;

    if (_state.isCommandPending) {
      return ControlCommandResult(
        commandId: 'REJECTED-INFLIGHT',
        type: CommandType.startIrrigation,
        outcome: CommandOutcome.rejected,
        message: 'A command is already pending execution. Concurrency lock active.',
        timestamp: DateTime.now(),
      );
    }

    final commandId = 'CMD-${DateTime.now().millisecondsSinceEpoch}';
    final command = ControlCommand(
      id: commandId,
      type: CommandType.startIrrigation,
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
    } catch (e) {
      final errorResult = ControlCommandResult(
        commandId: commandId,
        type: CommandType.startIrrigation,
        outcome: CommandOutcome.failed,
        message: 'Communication pipeline error: $e',
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

  Future<ControlCommandResult> stopIrrigation({
    required String requestedBy,
    ControlUserRole? role,
  }) async {
    final effectiveRole = role ?? _state.userRole;

    if (_state.isCommandPending) {
      return ControlCommandResult(
        commandId: 'REJECTED-INFLIGHT',
        type: CommandType.stopIrrigation,
        outcome: CommandOutcome.rejected,
        message: 'A command is already pending execution. Concurrency lock active.',
        timestamp: DateTime.now(),
      );
    }

    final commandId = 'CMD-${DateTime.now().millisecondsSinceEpoch}';
    final command = ControlCommand(
      id: commandId,
      type: CommandType.stopIrrigation,
      target: CentralControlTelemetry.fixedTarget,
      durationMinutes: 0,
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
    } catch (e) {
      final errorResult = ControlCommandResult(
        commandId: commandId,
        type: CommandType.stopIrrigation,
        outcome: CommandOutcome.failed,
        message: 'Communication pipeline error: $e',
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

  @override
  void dispose() {
    _isDisposed = true;
    _telemetrySub?.cancel();
    super.dispose();
  }
}
