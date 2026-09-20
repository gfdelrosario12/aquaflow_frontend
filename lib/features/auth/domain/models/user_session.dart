import 'auth_token.dart';
import 'user_role.dart';

class UserSession {
  final String userId;
  final String username;
  final String email;

  /// Legacy free-text role string (kept for backwards compatibility with
  /// any existing display code). For authorization decisions, use [role].
  final String role;

  final AuthToken token;

  const UserSession({
    required this.userId,
    required this.username,
    required this.email,
    required this.role,
    required this.token,
  });

  // ── Field-scoped claims ────────────────────────────────────────────────────

  /// The field this session is authorized for, derived from the token's
  /// field-scoped claim. Null until the backend embeds field claims.
  String? get fieldId => token.fieldId;

  /// The canonical authorization role for this session, derived from the
  /// token's role claim. Null when the claim is missing or unrecognized —
  /// treat as unauthorized.
  UserRole? get userRole => token.role;

  // ── Authorization helpers ──────────────────────────────────────────────────

  /// Returns true if this session's role meets or exceeds [required].
  ///
  /// Returns false when [userRole] is null (missing or unrecognized claim),
  /// preventing silent elevation to incorrect access levels.
  bool canPerform(UserRole required) {
    final r = userRole;
    if (r == null) return false;
    return r.satisfies(required);
  }

  /// Whether this session has the field-scoped claims needed for
  /// authorization enforcement. Use this as a guard in session restoration.
  bool get hasValidFieldClaims => token.hasFieldClaims;

  // ── Serialization ──────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'email': email,
      'role': role,
      'token': token.toJson(),
    };
  }

  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      userId: json['userId'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      token: AuthToken.fromJson(json['token'] as Map<String, dynamic>),
    );
  }

  UserSession copyWith({
    String? userId,
    String? username,
    String? email,
    String? role,
    AuthToken? token,
  }) {
    return UserSession(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
      token: token ?? this.token,
    );
  }
}
