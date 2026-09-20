import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/aqua_button.dart';
import '../../../core/widgets/aqua_card.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/loading_state_widget.dart';
import '../../../core/widgets/responsive_container.dart';
import '../../../core/widgets/status_badge.dart';
import '../../auth/domain/models/user_role.dart';
import '../domain/models/account_audit_event.dart';
import '../domain/models/audit_actor.dart';
import '../domain/models/audit_category.dart';
import '../domain/models/audit_result.dart';
import 'providers/audit_notifier.dart';

class AuditHistoryScreen extends StatefulWidget {
  final UserRole userRole;
  final AuditNotifier? notifier;

  const AuditHistoryScreen({
    super.key,
    this.userRole = UserRole.fieldAdmin,
    this.notifier,
  });

  @override
  State<AuditHistoryScreen> createState() => _AuditHistoryScreenState();
}

class _AuditHistoryScreenState extends State<AuditHistoryScreen> {
  late final AuditNotifier _notifier;
  final TextEditingController _actorSearchController = TextEditingController();
  final TextEditingController _targetSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _notifier = widget.notifier ?? AuditNotifier();
  }

  @override
  void dispose() {
    _actorSearchController.dispose();
    _targetSearchController.dispose();
    if (widget.notifier == null) {
      _notifier.dispose();
    }
    super.dispose();
  }

  bool get _isAuthorized =>
      widget.userRole == UserRole.fieldAdmin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!_isAuthorized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Account Audit Log')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spaceLg),
            child: EmptyStateWidget(
              title: 'Access Restricted',
              message:
                  'Audit log inspection requires Administrator or Field Admin privileges. Current role (${widget.userRole.name}) is not authorized.',
              icon: Icons.gavel,
            ),
          ),
        ),
      );
    }

    return ResponsiveContainer(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Unified Account Audit History'),
          actions: [
            ValueListenableBuilder<AuditStateData>(
              valueListenable: _notifier,
              builder: (context, state, _) {
                return IconButton(
                  icon: Icon(
                    state.isLiveFeedActive
                        ? Icons.sensors
                        : Icons.sensors_off,
                    color: state.isLiveFeedActive
                        ? AppColors.success
                        : theme.disabledColor,
                  ),
                  tooltip: state.isLiveFeedActive
                      ? 'Live Feed Active'
                      : 'Live Feed Paused',
                  onPressed: () =>
                      _notifier.toggleLiveFeed(!state.isLiveFeedActive),
                );
              },
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.download),
              tooltip: 'Export Audit Log',
              onSelected: (choice) => _handleExport(choice),
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'csv', child: Text('Export as CSV')),
                PopupMenuItem(value: 'json', child: Text('Export as JSON')),
              ],
            ),
          ],
        ),
        body: ValueListenableBuilder<AuditStateData>(
          valueListenable: _notifier,
          builder: (context, state, _) {
            if (state.isLoading && state.events.isEmpty) {
              return const LoadingStateWidget(
                message: 'Loading audit history records...',
              );
            }

            if (state.errorMessage != null && state.events.isEmpty) {
              return ErrorStateWidget(
                message: state.errorMessage!,
                onRetry: () => _notifier.loadAuditEvents(),
              );
            }

            return Column(
              children: [
                _buildFilterHeader(theme, state),
                Expanded(
                  child: state.events.isEmpty
                      ? const EmptyStateWidget(
                          title: 'No Matching Audit Events',
                          message:
                              'No audit log entries match the selected filters.',
                          icon: Icons.manage_search,
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(AppDimensions.spaceMd),
                          itemCount: state.events.length + (state.hasMorePages ? 1 : 0),
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: AppDimensions.spaceSm),
                          itemBuilder: (context, index) {
                            if (index == state.events.length) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(AppDimensions.spaceSm),
                                  child: AquaButton(
                                    label: 'Load More Audit Events',
                                    isFullWidth: false,
                                    onPressed: () =>
                                        _notifier.loadAuditEvents(refresh: false),
                                  ),
                                ),
                              );
                            }

                            final event = state.events[index];
                            return _buildAuditEventTile(theme, event);
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterHeader(ThemeData theme, AuditStateData state) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceMd,
        vertical: AppDimensions.spaceSm,
      ),
      color: theme.cardTheme.color ?? theme.colorScheme.surface,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<AuditCategory?>(
                  isExpanded: true,
                  value: state.filters.category,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Categories')),
                    ...AuditCategory.values.map(
                      (c) => DropdownMenuItem(value: c, child: Text(c.displayName)),
                    ),
                  ],
                  onChanged: (val) {
                    _notifier.applyFilters(
                      state.filters.copyWith(category: val, clearCategory: val == null),
                    );
                  },
                ),
              ),
              const SizedBox(width: AppDimensions.spaceSm),
              Expanded(
                child: DropdownButtonFormField<AuditResult?>(
                  isExpanded: true,
                  value: state.filters.result,
                  decoration: const InputDecoration(
                    labelText: 'Result',
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Outcomes')),
                    ...AuditResult.values.map(
                      (r) => DropdownMenuItem(value: r, child: Text(r.displayName)),
                    ),
                  ],
                  onChanged: (val) {
                    _notifier.applyFilters(
                      state.filters.copyWith(result: val, clearResult: val == null),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<DateTimeRangeFilter>(
                  value: state.filters.timeRange,
                  decoration: const InputDecoration(
                    labelText: 'Time Range',
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                  items: const [
                    DropdownMenuItem(value: DateTimeRangeFilter.all, child: Text('All Time')),
                    DropdownMenuItem(value: DateTimeRangeFilter.last24h, child: Text('Last 24 Hours')),
                    DropdownMenuItem(value: DateTimeRangeFilter.last7d, child: Text('Last 7 Days')),
                    DropdownMenuItem(value: DateTimeRangeFilter.last30d, child: Text('Last 30 Days')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      _notifier.applyFilters(state.filters.copyWith(timeRange: val));
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAuditEventTile(ThemeData theme, AccountAuditEvent event) {
    final Color resultColor;
    switch (event.result) {
      case AuditResult.success:
        resultColor = AppColors.success;
        break;
      case AuditResult.failed:
        resultColor = AppColors.error;
        break;
      case AuditResult.denied:
        resultColor = AppColors.warning;
        break;
      case AuditResult.partial:
        resultColor = AppColors.accent;
        break;
    }

    final IconData actorIcon;
    switch (event.actor.type) {
      case AuditActorType.user:
        actorIcon = Icons.person;
        break;
      case AuditActorType.system:
        actorIcon = Icons.auto_mode;
        break;
      case AuditActorType.emergencyOverride:
        actorIcon = Icons.warning_amber;
        break;
    }

    return AquaCard(
      child: InkWell(
        onTap: () => _showEventDetailSheet(context, theme, event),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(actorIcon, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    event.actor.displayName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: resultColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                    border: Border.all(color: resultColor),
                  ),
                  child: Text(
                    event.result.displayName.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: resultColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                StatusBadge(
                  label: event.category.displayName,
                  isCompact: true,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    event.action,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Target: ${event.target.displayName ?? event.target.id} (${event.target.type})',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
            ),
            if (event.metadata.rationale != null) ...[
              const SizedBox(height: 4),
              Text(
                'Rationale: ${event.metadata.rationale}',
                style: theme.textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (event.metadata.failureReason != null) ...[
              const SizedBox(height: 4),
              Text(
                'Failure Reason: ${event.metadata.failureReason}',
                style: theme.textTheme.bodySmall?.copyWith(color: AppColors.error),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                _formatTimestamp(event.timestamp),
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEventDetailSheet(
      BuildContext context, ThemeData theme, AccountAuditEvent event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(AppDimensions.spaceMd),
          height: MediaQuery.of(context).size.height * 0.75,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Audit Event Detail',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(),
                _detailRow('Event ID', event.eventId),
                _detailRow('Timestamp', event.timestamp.toIso8601String()),
                _detailRow('Actor Type', event.actor.type.name),
                _detailRow('Actor ID', event.actor.id),
                _detailRow('Actor Name', event.actor.displayName),
                _detailRow('Category', event.category.displayName),
                _detailRow('Action', event.action),
                _detailRow('Target Type', event.target.type),
                _detailRow('Target ID', event.target.id),
                if (event.target.displayName != null)
                  _detailRow('Target Label', event.target.displayName!),
                _detailRow('Result Outcome', event.result.displayName),
                if (event.metadata.rationale != null)
                  _detailRow('Rationale', event.metadata.rationale!),
                if (event.metadata.failureReason != null)
                  _detailRow('Failure Reason', event.metadata.failureReason!),
                if (event.metadata.clientIp != null)
                  _detailRow('Client IP', event.metadata.clientIp!),
                if (event.metadata.correlationId != null)
                  _detailRow('Correlation ID', event.metadata.correlationId!),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _handleExport(String format) {
    final isJson = format == 'json';
    final exported = _notifier.exportAuditEvents(isJson: isJson);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Audit log exported as ${format.toUpperCase()} (${exported.length} bytes)',
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    final dateStr = '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    final timeStr = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
    return '$dateStr $timeStr';
  }
}

