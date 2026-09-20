class AuditMetadata {
  final String? correlationId;
  final String? requestId;
  final String? clientIp;
  final Map<String, dynamic>? priorState;
  final Map<String, dynamic>? newState;
  final String? rationale;
  final String? failureReason;
  final Map<String, dynamic>? ext;

  const AuditMetadata({
    this.correlationId,
    this.requestId,
    this.clientIp,
    this.priorState,
    this.newState,
    this.rationale,
    this.failureReason,
    this.ext,
  });

  Map<String, dynamic> toJson() {
    return {
      if (correlationId != null) 'correlationId': correlationId,
      if (requestId != null) 'requestId': requestId,
      if (clientIp != null) 'clientIp': clientIp,
      if (priorState != null) 'priorState': priorState,
      if (newState != null) 'newState': newState,
      if (rationale != null) 'rationale': rationale,
      if (failureReason != null) 'failureReason': failureReason,
      if (ext != null) 'ext': ext,
    };
  }

  factory AuditMetadata.fromJson(Map<String, dynamic> json) {
    return AuditMetadata(
      correlationId: json['correlationId'] as String?,
      requestId: json['requestId'] as String?,
      clientIp: json['clientIp'] as String?,
      priorState: json['priorState'] != null
          ? Map<String, dynamic>.from(json['priorState'] as Map)
          : null,
      newState: json['newState'] != null
          ? Map<String, dynamic>.from(json['newState'] as Map)
          : null,
      rationale: json['rationale'] as String?,
      failureReason: json['failureReason'] as String?,
      ext: json['ext'] != null
          ? Map<String, dynamic>.from(json['ext'] as Map)
          : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuditMetadata &&
          runtimeType == other.runtimeType &&
          correlationId == other.correlationId &&
          requestId == other.requestId &&
          clientIp == other.clientIp &&
          rationale == other.rationale &&
          failureReason == other.failureReason;

  @override
  int get hashCode =>
      correlationId.hashCode ^
      requestId.hashCode ^
      clientIp.hashCode ^
      rationale.hashCode ^
      failureReason.hashCode;
}

