## MODIFIED Requirements

### Requirement: Node lifecycle operations are audited
The system SHALL audit all sensor-node lifecycle operations, including discovery, registration, provisioning, assignment, reassignment, interval configuration, lifecycle transitions, replacement, and decommissioning.

#### Scenario: Node registration is audited
- **WHEN** an authorized operator registers a new sensor node
- **THEN** the system SHALL create an audit event with `actor.type: user`, `category: node-management`, `action: node.register`, `result: success`, and metadata containing the node ID, MAC address, and field/zone assignment

#### Scenario: Node reassignment is audited
- **WHEN** an authorized operator reassigns a node to a different field or zone
- **THEN** the system SHALL create an audit event with `actor.type: user`, `category: node-management`, `action: node.reassign`, `result: success`, and metadata containing the previous and new field/zone IDs

#### Scenario: Node replacement is audited
- **WHEN** an authorized operator replaces a node
- **THEN** the system SHALL create an audit event with `actor.type: user`, `category: node-management`, `action: node.replace`, `result: success`, and metadata containing the old node ID, new node ID, and replacement reason

#### Scenario: Node decommissioning is audited
- **WHEN** an authorized operator decommissions a node
- **THEN** the system SHALL create an audit event with `actor.type: user`, `category: node-management`, `action: node.decommission`, `result: success`, and metadata containing the node ID and decommissioning reason

#### Scenario: Unauthorized node operation is audited
- **WHEN** a user without node lifecycle permissions attempts a node operation
- **THEN** the system SHALL create an audit event with `actor.type: user`, `category: authorization`, `action: node.lifecycle.denied`, `result: denied`, and metadata containing the denial reason
