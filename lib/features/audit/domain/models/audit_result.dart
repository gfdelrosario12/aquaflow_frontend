enum AuditResult {
  success,
  failed,
  denied,
  partial;

  String toJson() => name;

  static AuditResult fromJson(String json) {
    switch (json) {
      case 'success':
        return AuditResult.success;
      case 'failed':
      case 'failure':
        return AuditResult.failed;
      case 'denied':
        return AuditResult.denied;
      case 'partial':
        return AuditResult.partial;
      default:
        return AuditResult.failed;
    }
  }

  String get displayName {
    switch (this) {
      case AuditResult.success:
        return 'Success';
      case AuditResult.failed:
        return 'Failed';
      case AuditResult.denied:
        return 'Denied';
      case AuditResult.partial:
        return 'Partial';
    }
  }
}

