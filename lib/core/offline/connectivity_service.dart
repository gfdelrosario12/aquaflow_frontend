import 'dart:async';

import 'package:flutter/foundation.dart';

import 'offline_models.dart';

abstract class ConnectivityProbe {
  Future<bool> isBackendReachable();
  Stream<bool> watchBackendReachability();
}

class FakeConnectivityProbe implements ConnectivityProbe {
  final _controller = StreamController<bool>.broadcast();
  bool reachable;

  FakeConnectivityProbe({this.reachable = true});

  @override
  Future<bool> isBackendReachable() async => reachable;

  @override
  Stream<bool> watchBackendReachability() => _controller.stream;

  void setReachable(bool value) {
    reachable = value;
    _controller.add(value);
  }

  Future<void> dispose() => _controller.close();
}

class ConnectivityNotifier extends ChangeNotifier {
  final ConnectivityProbe probe;
  StreamSubscription<bool>? _subscription;
  ConnectivityState _state = ConnectivityState.degraded;
  bool _disposed = false;

  ConnectivityNotifier({ConnectivityProbe? probe}) : probe = probe ?? FakeConnectivityProbe() {
    _subscription = this.probe.watchBackendReachability().listen(_setReachability);
    refresh();
  }

  ConnectivityState get state => _state;
  bool get canReachBackend => _state == ConnectivityState.online;

  Future<void> refresh() async => _setReachability(await probe.isBackendReachable());

  void markSynchronizing() => _setState(ConnectivityState.synchronizing);

  void markRecovery() => _setState(ConnectivityState.recovery);

  void _setReachability(bool reachable) =>
      _setState(reachable ? ConnectivityState.online : ConnectivityState.offline);

  void _setState(ConnectivityState state) {
    _state = state;
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    super.dispose();
  }
}
