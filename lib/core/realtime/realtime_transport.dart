import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

abstract class RealtimeTransport {
  Stream<String> get messages;
  Stream<Object> get errors;
  bool get isConnected;

  Future<void> connect(Uri endpoint, {required String accessToken});
  Future<void> subscribe(List<String> topics);
  Future<void> close();
}

class WebSocketRealtimeTransport implements RealtimeTransport {
  WebSocketChannel? _channel;
  StreamSubscription<Object?>? _subscription;
  final _messages = StreamController<String>.broadcast();
  final _errors = StreamController<Object>.broadcast();
  bool _connected = false;

  @override
  Stream<String> get messages => _messages.stream;

  @override
  Stream<Object> get errors => _errors.stream;

  @override
  bool get isConnected => _connected;

  @override
  Future<void> connect(Uri endpoint, {required String accessToken}) async {
    await close();
    final uri = endpoint.replace(
      queryParameters: {...endpoint.queryParameters, 'access_token': accessToken},
    );
    _channel = WebSocketChannel.connect(uri);
    await _channel!.ready;
    _connected = true;
    _subscription = _channel!.stream.listen(
      (message) {
        if (message is String) _messages.add(message);
      },
      onError: (Object error) {
        _connected = false;
        _errors.add(error);
      },
      onDone: () => _connected = false,
    );
  }

  @override
  Future<void> subscribe(List<String> topics) async {
    if (!_connected || _channel == null) {
      throw StateError('Realtime transport is not connected.');
    }
    _channel!.sink.add(jsonEncode({'type': 'subscribe', 'topics': topics}));
  }

  @override
  Future<void> close() async {
    _connected = false;
    await _subscription?.cancel();
    _subscription = null;
    await _channel?.sink.close();
    _channel = null;
  }
  Future<void> dispose() async {
    await close();
    await _messages.close();
    await _errors.close();
  }
}

class FakeRealtimeTransport implements RealtimeTransport {
  final _messages = StreamController<String>.broadcast();
  final _errors = StreamController<Object>.broadcast();
  final List<List<String>> subscriptions = [];
  bool _connected = false;
  int connectCount = 0;

  @override
  Stream<String> get messages => _messages.stream;

  @override
  Stream<Object> get errors => _errors.stream;

  @override
  bool get isConnected => _connected;

  @override
  Future<void> connect(Uri endpoint, {required String accessToken}) async {
    if (accessToken.isEmpty) throw StateError('Access token is required.');
    connectCount++;
    _connected = true;
  }

  @override
  Future<void> subscribe(List<String> topics) async {
    if (!_connected) throw StateError('Transport is disconnected.');
    subscriptions.add(List.unmodifiable(topics));
  }

  void emit(String message) {
    if (_connected) _messages.add(message);
  }

  void fail(Object error) {
    _connected = false;
    _errors.add(error);
  }

  @override
  Future<void> close() async {
    _connected = false;
  }

  Future<void> dispose() async {
    await close();
    await _messages.close();
    await _errors.close();
  }
}
