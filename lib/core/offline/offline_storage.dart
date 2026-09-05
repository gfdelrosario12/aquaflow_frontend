import 'dart:convert';

abstract class OfflineStorage {
  Future<void> write(String key, Map<String, Object?> value);
  Future<Map<String, Object?>?> read(String key);
  Future<void> delete(String key);
  Future<void> clear();
}

class MemoryOfflineStorage implements OfflineStorage {
  final Map<String, Map<String, Object?>> _values = {};

  @override
  Future<void> write(String key, Map<String, Object?> value) async {
    _values[key] = Map<String, Object?>.from(value);
  }

  @override
  Future<Map<String, Object?>?> read(String key) async {
    final value = _values[key];
    return value == null ? null : Map<String, Object?>.from(value);
  }

  @override
  Future<void> delete(String key) async => _values.remove(key);

  @override
  Future<void> clear() async => _values.clear();
}

class JsonOfflineStorage implements OfflineStorage {
  final Map<String, String> _values = {};

  @override
  Future<void> write(String key, Map<String, Object?> value) async {
    _values[key] = jsonEncode(value);
  }

  @override
  Future<Map<String, Object?>?> read(String key) async {
    final raw = _values[key];
    if (raw == null) return null;
    final decoded = jsonDecode(raw);
    return decoded is Map
        ? Map<String, Object?>.from(decoded)
        : null;
  }

  @override
  Future<void> delete(String key) async => _values.remove(key);

  @override
  Future<void> clear() async => _values.clear();
}
