import 'package:flutter_test/flutter_test.dart';
import 'package:aquaflow_frontend/core/api/api_dtos.dart';

void main() {
  group('AccountAuditEventDto Tests', () {
    test('AuditActorDto serialization', () {
      const dto = AuditActorDto(type: 'user', id: 'usr-1', displayName: 'Maria');
      final json = dto.toJson();
      final fromJson = AuditActorDto.fromJson(json);

      expect(fromJson.type, 'user');
      expect(fromJson.id, 'usr-1');
      expect(fromJson.displayName, 'Maria');
    });

    test('AccountAuditEventDto list parsing', () {
      final jsonList = [
        {
          'eventId': 'ev-1',
          'timestamp': '2026-09-20T12:00:00Z',
          'actor': {'type': 'system', 'id': 'sys-1', 'displayName': 'System'},
          'category': 'irrigation',
          'action': 'auto.start',
          'target': {'type': 'field', 'id': 'f-1'},
          'result': 'success',
          'metadata': {'rationale': 'Moisture deficit'},
        }
      ];

      final listDto = AccountAuditEventListDto.fromJson(jsonList);
      expect(listDto.items.length, 1);
      expect(listDto.items.first.eventId, 'ev-1');
      expect(listDto.items.first.category, 'irrigation');
    });
  });
}

