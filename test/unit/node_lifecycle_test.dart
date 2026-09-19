import 'package:aquaflow_frontend/features/nodes/domain/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NodeLifecycleStatus state machine transitions', () {
    test('discovered node valid and invalid transitions', () {
      const status = NodeLifecycleStatus.discovered;
      expect(status.canTransitionTo(NodeLifecycleStatus.provisioned), isTrue);
      expect(status.canTransitionTo(NodeLifecycleStatus.decommissioned), isTrue);

      // Discovered cannot jump directly to active or replaced
      expect(status.canTransitionTo(NodeLifecycleStatus.active), isFalse);
      expect(status.canTransitionTo(NodeLifecycleStatus.replaced), isFalse);
      expect(status.canTransitionTo(NodeLifecycleStatus.maintenance), isFalse);
    });

    test('provisioned node transitions', () {
      const status = NodeLifecycleStatus.provisioned;
      expect(status.canTransitionTo(NodeLifecycleStatus.active), isTrue);
      expect(status.canTransitionTo(NodeLifecycleStatus.maintenance), isTrue);
      expect(status.canTransitionTo(NodeLifecycleStatus.decommissioned), isTrue);

      expect(status.canTransitionTo(NodeLifecycleStatus.discovered), isFalse);
      expect(status.canTransitionTo(NodeLifecycleStatus.replaced), isFalse);
    });

    test('active node transitions', () {
      const status = NodeLifecycleStatus.active;
      expect(status.canTransitionTo(NodeLifecycleStatus.maintenance), isTrue);
      expect(status.canTransitionTo(NodeLifecycleStatus.disabled), isTrue);
      expect(status.canTransitionTo(NodeLifecycleStatus.replaced), isTrue);
      expect(status.canTransitionTo(NodeLifecycleStatus.decommissioned), isTrue);

      expect(status.canTransitionTo(NodeLifecycleStatus.discovered), isFalse);
      expect(status.canTransitionTo(NodeLifecycleStatus.provisioned), isFalse);
    });

    test('maintenance node transitions', () {
      const status = NodeLifecycleStatus.maintenance;
      expect(status.canTransitionTo(NodeLifecycleStatus.active), isTrue);
      expect(status.canTransitionTo(NodeLifecycleStatus.disabled), isTrue);
      expect(status.canTransitionTo(NodeLifecycleStatus.replaced), isTrue);
      expect(status.canTransitionTo(NodeLifecycleStatus.decommissioned), isTrue);

      expect(status.canTransitionTo(NodeLifecycleStatus.discovered), isFalse);
    });

    test('disabled node transitions', () {
      const status = NodeLifecycleStatus.disabled;
      expect(status.canTransitionTo(NodeLifecycleStatus.active), isTrue);
      expect(status.canTransitionTo(NodeLifecycleStatus.maintenance), isTrue);
      expect(status.canTransitionTo(NodeLifecycleStatus.decommissioned), isTrue);

      expect(status.canTransitionTo(NodeLifecycleStatus.discovered), isFalse);
      expect(status.canTransitionTo(NodeLifecycleStatus.provisioned), isFalse);
    });

    test('replaced node transitions', () {
      const status = NodeLifecycleStatus.replaced;
      expect(status.isRetired, isTrue);
      expect(status.isTerminal, isFalse);
      expect(status.canTransitionTo(NodeLifecycleStatus.decommissioned), isTrue);

      // Replaced node cannot be reactivated or repaired
      expect(status.canTransitionTo(NodeLifecycleStatus.active), isFalse);
      expect(status.canTransitionTo(NodeLifecycleStatus.maintenance), isFalse);
      expect(status.canTransitionTo(NodeLifecycleStatus.disabled), isFalse);
    });

    test('decommissioned node is strictly terminal', () {
      const status = NodeLifecycleStatus.decommissioned;
      expect(status.isRetired, isTrue);
      expect(status.isTerminal, isTrue);

      for (final target in NodeLifecycleStatus.values.where((s) => s != NodeLifecycleStatus.decommissioned)) {
        expect(
          status.canTransitionTo(target),
          isFalse,
          reason: 'Decommissioned node must not transition to ${target.name}',
        );
      }
    });

    test('validateTransition throws StateError on illegal transitions', () {
      expect(
        () => NodeLifecycleStatus.discovered.validateTransition(NodeLifecycleStatus.active),
        throwsStateError,
      );

      expect(
        () => NodeLifecycleStatus.decommissioned.validateTransition(NodeLifecycleStatus.active),
        throwsStateError,
      );

      expect(
        () => NodeLifecycleStatus.active.validateTransition(NodeLifecycleStatus.maintenance),
        returnsNormally,
      );
    });
  });
}
