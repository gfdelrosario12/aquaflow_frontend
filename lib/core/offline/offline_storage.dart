import 'dart:convert';

import '../security/sensitive_data_redactor.dart';

abstract class OfflineStorage {
  Future<void> write(String key, Map<String, Object?> value);
  Future<Map<String, Object?>?> read(String key);
  Future<void> delete(String key);
  Future<void> clear();
}

/// Strips credentials and auth material before offline persistence.
Map<String, Object?> scrubOfflinePayload(Map<String, Object?> value) {
  final result = <String, Object?>{};
  value.forEach((key, raw) {
    final lower = key.toLowerCase();
    if (SensitiveDataRedactor.sensitiveKeys.contains(key) ||
        SensitiveDataRedactor.sensitiveKeys.contains(lower) ||
        lower.contains('password') ||
        lower.contains('token') ||
        lower == 'authorization') {
      return;
    }
    if (raw is Map) {
      result[key] = scrubOfflinePayload(Map<String, Object?>.from(raw));
    } else if (raw is List) {
      result[key] = raw.map((item) {
        if (item is Map) {
          return scrubOfflinePayload(Map<String, Object?>.from(item));
        }
        return item;
      }).toList();
    } else {
      result[key] = raw;
    }
  });
  return result;
}

class MemoryOfflineStorage implements OfflineStorage {
  final Map<String, Map<String, Object?>> _values = {};

  @override
  Future<void> write(String key, Map<String, Object?> value) async {
    _values[key] = scrubOfflinePayload(value);
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
    _values[key] = jsonEncode(scrubOfflinePayload(value));
  }

  @override
  Future<Map<String, Object?>?> read(String key) async {
    final raw = _values[key];
    if (raw == null) return null;
    final decoded = jsonDecode(raw);
    return decoded is Map ? Map<String, Object?>.from(decoded) : null;
  }

  @override
  Future<void> delete(String key) async => _values.remove(key);

  @override
  Future<void> clear() async => _values.clear();
}
