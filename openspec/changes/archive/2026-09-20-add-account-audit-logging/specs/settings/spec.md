## MODIFIED Requirements

### Requirement: Settings changes are audited
The system SHALL audit all settings and configuration changes, including field configuration, irrigation configuration, notification preferences, and security-related settings.

#### Scenario: User changes irrigation configuration
- **WHEN** an authorized user changes irrigation configuration settings
- **THEN** the system SHALL create an audit event with `actor.type: user`, `category: field-config` or `category: irrigation`, `action: irrigation.config.update`, `result: success`, and metadata containing the old and new configuration values

#### Scenario: User changes notification preferences
- **WHEN** an authorized user changes notification preferences
- **THEN** the system SHALL create an audit event with `actor.type: user`, `category: settings`, `action: settings.notifications.update`, `result: success`, and metadata containing the old and new notification settings

#### Scenario: User changes security settings
- **WHEN** an authorized user changes security-related settings
- **THEN** the system SHALL create an audit event with `actor.type: user`, `category: security`, `action: security.settings.update`, `result: success`, and metadata containing the old and new security settings
