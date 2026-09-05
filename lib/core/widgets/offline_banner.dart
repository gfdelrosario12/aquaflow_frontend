import 'package:flutter/material.dart';
import '../offline/offline_models.dart';

class OfflineBanner extends StatelessWidget {
  final ConnectivityState state;
  final String? message;

  const OfflineBanner({
    super.key,
    required this.state,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    if (state == ConnectivityState.online) return const SizedBox.shrink();
    final isSyncing = state == ConnectivityState.synchronizing ||
        state == ConnectivityState.recovery;
    final label = message ?? (isSyncing
        ? 'Recovering live data...'
        : 'Offline or degraded connection. Cached data may be stale.');
    return MaterialBanner(
      leading: Icon(isSyncing ? Icons.sync : Icons.cloud_off_outlined),
      content: Text(label),
      actions: const [SizedBox.shrink()],
    );
  }
}
