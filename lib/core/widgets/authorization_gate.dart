import 'package:flutter/material.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/domain/models/user_role.dart';

/// A widget that conditionally renders its child based on the current
/// user's role. If the user's role is insufficient, the child is hidden
/// (or replaced with a placeholder) without revealing any role/token details.
///
/// Usage:
/// ```dart
/// AuthorizationGate(
///   requiredRole: UserRole.operator,
///   child: ElevatedButton(
///     onPressed: startIrrigation,
///     child: const Text('Start Irrigation'),
///   ),
/// )
/// ```
class AuthorizationGate extends StatelessWidget {
  /// The minimum role required to view the child.
  final UserRole requiredRole;

  /// The widget to render when the user has sufficient permissions.
  final Widget child;

  /// Optional placeholder to show when the user lacks permissions.
  /// If null, nothing is rendered (zero-sized box).
  final Widget? placeholder;

  /// Whether to show a disabled version of the child instead of hiding it.
  /// When true, wraps child in an IgnorePointer and applies opacity.
  final bool showDisabled;

  /// The auth notifier to listen to. If not provided, uses [globalAuthNotifier].
  final AuthNotifier? authNotifier;

  const AuthorizationGate({
    super.key,
    required this.requiredRole,
    required this.child,
    this.placeholder,
    this.showDisabled = false,
    this.authNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final notifier = authNotifier ?? globalAuthNotifier;
    return ValueListenableBuilder<AuthState>(
      valueListenable: notifier,
      builder: (context, authState, _) {
        final canAccess = authState.canPerform(requiredRole);

        if (canAccess) {
          return child;
        }

        if (showDisabled) {
          return IgnorePointer(
            child: Opacity(
              opacity: 0.5,
              child: child,
            ),
          );
        }

        return placeholder ?? const SizedBox.shrink();
      },
    );
  }
}

/// Convenience builder for checking permissions in widget trees
/// without wrapping in AuthorizationGate.
class AuthorizationGateBuilder extends StatelessWidget {
  final UserRole requiredRole;
  final Widget Function(bool hasPermission) builder;

  /// The auth notifier to listen to. If not provided, uses [globalAuthNotifier].
  final AuthNotifier? authNotifier;

  const AuthorizationGateBuilder({
    super.key,
    required this.requiredRole,
    required this.builder,
    this.authNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final notifier = authNotifier ?? globalAuthNotifier;
    return ValueListenableBuilder<AuthState>(
      valueListenable: notifier,
      builder: (context, authState, _) {
        return builder(authState.canPerform(requiredRole));
      },
    );
  }
}