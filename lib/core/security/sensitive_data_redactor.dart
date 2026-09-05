/// Redacts tokens, passwords, and Authorization values from logs and diagnostics.
class SensitiveDataRedactor {
  static const redacted = '[REDACTED]';

  static final RegExp _bearerPattern = RegExp(
    r'(Bearer\s+)[^\s,;]+',
    caseSensitive: false,
  );

  static final Set<String> sensitiveKeys = {
    'authorization',
    'password',
    'passwd',
    'secret',
    'accessToken',
    'access_token',
    'refreshToken',
    'refresh_token',
    'token',
    'apiKey',
    'api_key',
  };

  static String redactString(String input) {
    var output = input.replaceAllMapped(
      _bearerPattern,
      (match) => '${match.group(1)}$redacted',
    );
    for (final key in sensitiveKeys) {
      output = output.replaceAllMapped(
        RegExp(
          '("$key"\\s*:\\s*")([^"]*)(")',
          caseSensitive: false,
        ),
        (match) => '${match.group(1)}$redacted${match.group(3)}',
      );
      output = output.replaceAllMapped(
        RegExp(
          "('$key'\\s*:\\s*')([^']*)(')",
          caseSensitive: false,
        ),
        (match) => '${match.group(1)}$redacted${match.group(3)}',
      );
    }
    return output;
  }

  static Map<String, String> redactHeaders(Map<String, String> headers) {
    return headers.map((key, value) {
      if (sensitiveKeys.contains(key.toLowerCase()) ||
          key.toLowerCase() == 'authorization') {
        return MapEntry(key, redacted);
      }
      return MapEntry(key, value);
    });
  }

  static Map<String, Object?> redactMap(Map<String, Object?> input) {
    final result = <String, Object?>{};
    input.forEach((key, value) {
      if (sensitiveKeys.contains(key) ||
          sensitiveKeys.contains(key.toLowerCase())) {
        result[key] = redacted;
      } else if (value is Map) {
        result[key] = redactMap(Map<String, Object?>.from(value));
      } else if (value is List) {
        result[key] = value.map((item) {
          if (item is Map) {
            return redactMap(Map<String, Object?>.from(item));
          }
          if (item is String) return redactString(item);
          return item;
        }).toList();
      } else if (value is String) {
        result[key] = redactString(value);
      } else {
        result[key] = value;
      }
    });
    return result;
  }
}
