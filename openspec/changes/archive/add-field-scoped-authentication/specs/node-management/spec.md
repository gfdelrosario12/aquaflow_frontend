## MODIFIED Requirements

### Requirement: Node transmission interval configuration
The system SHALL display the active transmission interval (in seconds) for each node and allow users with `operator` or `field_admin` roles to configure the base reporting interval. Users with `viewer` role MUST NOT be permitted to modify transmission intervals. Authorization is enforced by the backend using field-scoped JWT claims; the Flutter client MUST also hide or disable interval controls for `viewer` sessions.

#### Scenario: Authorized operator updates transmission interval
- **WHEN** an authenticated user with `operator` or `field_admin` role updates the transmission interval of a node to 60 seconds
- **THEN** the system dispatches the configuration command to the backend and updates the displayed interval upon acknowledgment.

#### Scenario: Unauthorized viewer attempts interval configuration
- **WHEN** an authenticated user with `viewer` role accesses the node details
- **THEN** transmission interval controls are disabled or read-only in the Flutter UI, and any backend request to modify the interval is rejected with HTTP 403.

### Requirement: Role-based authorization for node lifecycle operations
The system MUST enforce role-based access control on all node lifecycle operations using field-scoped JWT claims validated server-side. Only authenticated users with `operator` or `field_admin` roles SHALL be permitted to register, provision, assign, reassign, rename, toggle maintenance, replace, or decommission nodes. Users with `viewer` role MUST NOT have access to lifecycle mutation actions. The Flutter client MUST additionally hide or disable mutation controls for `viewer` sessions, but this client-side gating does not substitute for backend enforcement.

#### Scenario: Operator performs a node lifecycle operation
- **WHEN** a user authenticated with `operator` or `field_admin` role initiates a node registration, provisioning, lifecycle transition, or replacement
- **THEN** the backend validates the role claim, authorizes the operation, and executes it.

#### Scenario: Unauthorized viewer attempts node lifecycle operation
- **WHEN** a user authenticated with `viewer` role attempts to decommission, replace, or otherwise mutate a node's lifecycle state
- **THEN** the Flutter client hides or disables mutation controls, any backend request returns HTTP 403, and a role-insufficient warning is displayed.

#### Scenario: field_admin manages node membership across field
- **WHEN** a user authenticated with `field_admin` role assigns or reassigns a node to a zone within their field
- **THEN** the backend validates the `field_admin` role and the matching `fieldId` claim before executing the assignment.
