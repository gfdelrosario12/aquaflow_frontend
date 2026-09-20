enum AuditCategory {
  authentication,
  authorization,
  fieldConfig,
  nodeManagement,
  sensorConfig,
  irrigation,
  security,
  system;

  String toJson() => name;

  static AuditCategory fromJson(String json) {
    switch (json) {
      case 'authentication':
      case 'auth':
        return AuditCategory.authentication;
      case 'authorization':
        return AuditCategory.authorization;
      case 'fieldConfig':
      case 'field_config':
      case 'field-config':
        return AuditCategory.fieldConfig;
      case 'nodeManagement':
      case 'node_management':
      case 'node-management':
        return AuditCategory.nodeManagement;
      case 'sensorConfig':
      case 'sensor_config':
      case 'sensor-config':
        return AuditCategory.sensorConfig;
      case 'irrigation':
        return AuditCategory.irrigation;
      case 'security':
        return AuditCategory.security;
      case 'system':
      default:
        return AuditCategory.system;
    }
  }

  String get displayName {
    switch (this) {
      case AuditCategory.authentication:
        return 'Authentication';
      case AuditCategory.authorization:
        return 'Authorization';
      case AuditCategory.fieldConfig:
        return 'Field Configuration';
      case AuditCategory.nodeManagement:
        return 'Node Management';
      case AuditCategory.sensorConfig:
        return 'Sensor Configuration';
      case AuditCategory.irrigation:
        return 'Irrigation Execution';
      case AuditCategory.security:
        return 'Mobile Security';
      case AuditCategory.system:
        return 'System Maintenance';
    }
  }
}

