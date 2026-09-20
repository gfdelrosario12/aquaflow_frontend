import 'dart:convert';

import 'user_role.dart';

class AuthToken {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;

  /// The field this token grants access to, parsed from the JWT `fieldId` claim.
  /// Null when the backend has not yet embedded field-scoped claims.
  final String? fieldId;

  /// The authorization role, parsed from the JWT `role` claim.
  /// Null when the claim is missing or unrecognized.
  final UserRole? role;

  const AuthToken({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    this.fieldId,
    this.role,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Whether the token carries the field-scoped claims required for
  /// authorization enforcement.
  bool get hasFieldClaims => fieldId != null && role != null;

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiresAt': expiresAt.toIso8601String(),
      if (fieldId != null) 'fieldId': fieldId,
      if (role != null) 'role': role!.claimValue,
    };
  }

  factory AuthToken.fromJson(Map<String, dynamic> json) {
    return AuthToken(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      fieldId: json['fieldId'] as String?,
      role: UserRole.fromString(json['role'] as String?),
    );
  }

  /// Parses a JWT access token and extracts field-scoped claims from its
  /// payload. Returns a copy of [base] enriched with any claims found.
  ///
  /// Silently ignores malformed payloads — the safe fallback is no claims
  /// (treated as unauthorized by [UserSession]).
  static AuthToken withClaimsFromJwt(AuthToken base) {
    try {
      final parts = base.accessToken.split('.');
      if (parts.length < 2) return base;

      // Standard Base64url padding
      String padded = parts[1];
      final remainder = padded.length % 4;
      if (remainder != 0) {
        padded = padded.padRight(padded.length + (4 - remainder), '=');
      }

      final decoded = utf8.decode(base64Url.decode(padded));
      final payload = jsonDecode(decoded) as Map<String, dynamic>;

      final fieldId =
          (payload['fieldId'] ?? payload['field_id'])?.toString();
      final roleStr =
          (payload['role'] ?? payload['user_role'])?.toString();

      return AuthToken(
        accessToken: base.accessToken,
        refreshToken: base.refreshToken,
        expiresAt: base.expiresAt,
        fieldId: fieldId,
        role: UserRole.fromString(roleStr),
      );
    } catch (_) {
      return base;
    }
  }
}
