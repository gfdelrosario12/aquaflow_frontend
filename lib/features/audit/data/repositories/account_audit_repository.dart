import '../../../../core/api/api_mappers.dart';
import '../../../../core/api/api_services.dart';
import '../../domain/models/account_audit_event.dart';
import '../../domain/models/audit_actor.dart';
import '../../domain/models/audit_category.dart';
import '../../domain/models/audit_metadata.dart';
import '../../domain/models/audit_result.dart';
import '../../domain/models/audit_target.dart';

abstract class AccountAuditRepository {
  Future<List<AccountAuditEvent>> fetchAuditEvents({
    AuditCategory? category,
    String? actorId,
    String? targetType,
    String? targetId,
    DateTime? from,
    DateTime? to,
    int limit = 50,
    int offset = 0,
  });

  Future<AccountAuditEvent?> fetchAuditEvent(String eventId);

  /// Local/Mock emission helper for UI/dev simulation
  Future<void> emitAuditEvent(AccountAuditEvent event);
}

class AccountAuditRepositoryImpl implements AccountAuditRepository {
  final AccountAuditApiService _apiService;
  final List<AccountAuditEvent> _localCache = [];

  AccountAuditRepositoryImpl(this._apiService);

  @override
  Future<List<AccountAuditEvent>> fetchAuditEvents({
    AuditCategory? category,
    String? actorId,
    String? targetType,
    String? targetId,
    DateTime? from,
    DateTime? to,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final dtoList = await _apiService.getAuditEvents(
        category: category?.name,
        actorId: actorId,
        targetType: targetType,
        targetId: targetId,
        from: from,
        to: to,
        limit: limit,
        offset: offset,
      );
      final events = dtoList.items.map(ApiMappers.accountAuditEvent).toList();
      return events;
    } catch (_) {
      // Fallback to local cache if network/API unavailable
      return _queryCache(
        category: category,
        actorId: actorId,
        targetType: targetType,
        targetId: targetId,
        from: from,
        to: to,
        limit: limit,
        offset: offset,
      );
    }
  }

  @override
  Future<AccountAuditEvent?> fetchAuditEvent(String eventId) async {
    try {
      final dto = await _apiService.getAuditEvent(eventId);
      return ApiMappers.accountAuditEvent(dto);
    } catch (_) {
      try {
        return _localCache.firstWhere((e) => e.eventId == eventId);
      } catch (_) {
        return null;
      }
    }
  }

  @override
  Future<void> emitAuditEvent(AccountAuditEvent event) async {
    _localCache.insert(0, event);
  }

  List<AccountAuditEvent> _queryCache({
    AuditCategory? category,
    String? actorId,
    String? targetType,
    String? targetId,
    DateTime? from,
    DateTime? to,
    int limit = 50,
    int offset = 0,
  }) {
    var filtered = _localCache.where((e) {
      if (category != null && e.category != category) return false;
      if (actorId != null && actorId.isNotEmpty && e.actor.id != actorId) return false;
      if (targetType != null && targetType.isNotEmpty && e.target.type != targetType) return false;
      if (targetId != null && targetId.isNotEmpty && e.target.id != targetId) return false;
      if (from != null && e.timestamp.isBefore(from)) return false;
      if (to != null && e.timestamp.isAfter(to)) return false;
      return true;
    }).toList();

    filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final start = offset.clamp(0, filtered.length);
    final end = (offset + limit).clamp(0, filtered.length);
    return filtered.sublist(start, end);
  }
}

class MockAccountAuditRepository implements AccountAuditRepository {
  final List<AccountAuditEvent> _events = [];

  MockAccountAuditRepository() {
    _seedMockData();
  }

  void _seedMockData() {
    final now = DateTime.now();
    _events.addAll([
      AccountAuditEvent(
        eventId: 'aud-101',
        timestamp: now.subtract(const Duration(minutes: 5)),
        actor: const AuditActor(
          type: AuditActorType.user,
          id: 'usr-admin-01',
          displayName: 'Maria Santos (Admin)',
        ),
        category: AuditCategory.authentication,
        action: 'auth.login.success',
        target: const AuditTarget(type: 'session', id: 'sess-881', displayName: 'Web Dashboard Session'),
        result: AuditResult.success,
        metadata: const AuditMetadata(
          clientIp: '192.168.1.45',
          rationale: 'Successful password + MFA authentication',
        ),
      ),
      AccountAuditEvent(
        eventId: 'aud-102',
        timestamp: now.subtract(const Duration(minutes: 12)),
        actor: AuditActor.system('sys-auto-irrigation', 'Auto-AWD Supervisor'),
        category: AuditCategory.irrigation,
        action: 'irrigation.auto.evaluated',
        target: const AuditTarget(type: 'field', id: 'field-1', displayName: 'Central Field North'),
        result: AuditResult.success,
        metadata: const AuditMetadata(
          rationale: 'Field water deficit -12.5 cm triggered automatic 45m irrigation cycle',
        ),
      ),
      AccountAuditEvent(
        eventId: 'aud-103',
        timestamp: now.subtract(const Duration(minutes: 30)),
        actor: const AuditActor(
          type: AuditActorType.user,
          id: 'usr-op-02',
          displayName: 'Juan Dela Cruz (Operator)',
        ),
        category: AuditCategory.nodeManagement,
        action: 'node.reassign',
        target: const AuditTarget(type: 'node', id: 'SN-003', displayName: 'Sensor Node 003'),
        result: AuditResult.success,
        metadata: const AuditMetadata(
          priorState: {'zone': 'Q3'},
          newState: {'zone': 'Q2'},
          rationale: 'Reassigned physical node to dry zone Q2',
        ),
      ),
      AccountAuditEvent(
        eventId: 'aud-104',
        timestamp: now.subtract(const Duration(hours: 1, minutes: 15)),
        actor: const AuditActor(
          type: AuditActorType.user,
          id: 'usr-unauth',
          displayName: 'Unknown User (Guest)',
        ),
        category: AuditCategory.authorization,
        action: 'settings.safety.update',
        target: const AuditTarget(type: 'settings', id: 'safety-config'),
        result: AuditResult.denied,
        metadata: const AuditMetadata(
          failureReason: 'User role viewer lacks fieldAdmin permission',
        ),
      ),
      AccountAuditEvent(
        eventId: 'aud-105',
        timestamp: now.subtract(const Duration(hours: 2)),
        actor: const AuditActor(
          type: AuditActorType.emergencyOverride,
          id: 'usr-admin-01',
          displayName: 'Maria Santos (Emergency Override)',
        ),
        category: AuditCategory.irrigation,
        action: 'irrigation.manual.start',
        target: const AuditTarget(type: 'pump', id: 'PUMP-01', displayName: 'Central Station Pump'),
        result: AuditResult.success,
        metadata: const AuditMetadata(
          rationale: 'Manual emergency flush required due to canal siltation',
        ),
      ),
    ]);
  }

  @override
  Future<List<AccountAuditEvent>> fetchAuditEvents({
    AuditCategory? category,
    String? actorId,
    String? targetType,
    String? targetId,
    DateTime? from,
    DateTime? to,
    int limit = 50,
    int offset = 0,
  }) async {
    var filtered = _events.where((e) {
      if (category != null && e.category != category) return false;
      if (actorId != null && actorId.isNotEmpty && e.actor.id != actorId) return false;
      if (targetType != null && targetType.isNotEmpty && e.target.type != targetType) return false;
      if (targetId != null && targetId.isNotEmpty && e.target.id != targetId) return false;
      if (from != null && e.timestamp.isBefore(from)) return false;
      if (to != null && e.timestamp.isAfter(to)) return false;
      return true;
    }).toList();

    filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final start = offset.clamp(0, filtered.length);
    final end = (offset + limit).clamp(0, filtered.length);
    return filtered.sublist(start, end);
  }

  @override
  Future<AccountAuditEvent?> fetchAuditEvent(String eventId) async {
    try {
      return _events.firstWhere((e) => e.eventId == eventId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> emitAuditEvent(AccountAuditEvent event) async {
    _events.insert(0, event);
  }
}

