import 'auth_token.dart';

class UserSession {
  final String userId;
  final String username;
  final String email;
  final String role;
  final AuthToken token;

  const UserSession({
    required this.userId,
    required this.username,
    required this.email,
    required this.role,
    required this.token,
  });

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
}
