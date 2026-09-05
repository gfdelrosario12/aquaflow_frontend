typedef JsonMap = Map<String, dynamic>;

class ResourceDto {
  final String? id;
  final JsonMap data;

  const ResourceDto({this.id, required this.data});

  factory ResourceDto.fromJson(Object? json) {
    if (json is! JsonMap) {
      throw const FormatException('Expected a JSON object.');
    }
    final rawId = json['id'];
    return ResourceDto(
      id: rawId?.toString(),
      data: Map<String, dynamic>.from(json),
    );
  }
}

class ResourceListDto {
  final List<ResourceDto> items;

  const ResourceListDto(this.items);

  factory ResourceListDto.fromJson(Object? json) {
    final rawItems = json is List
        ? json
        : json is JsonMap && json['items'] is List
            ? json['items'] as List
            : const [];
    return ResourceListDto(
      rawItems.map(ResourceDto.fromJson).toList(growable: false),
    );
  }
}

class AuthResponseDto {
  final String accessToken;
  final String? refreshToken;
  final JsonMap user;

  const AuthResponseDto({
    required this.accessToken,
    this.refreshToken,
    required this.user,
  });

  factory AuthResponseDto.fromJson(Object? json) {
    if (json is! JsonMap || json['accessToken'] is! String) {
      throw const FormatException('Authentication response is missing accessToken.');
    }
    return AuthResponseDto(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String?,
      user: json['user'] is JsonMap
          ? Map<String, dynamic>.from(json['user'] as JsonMap)
          : const {},
    );
  }
}

class IrrigationCommandDto {
  static const entireField = 'ENTIRE FIELD';

  final String target;
  final int? durationMinutes;

  const IrrigationCommandDto({
    this.target = entireField,
    this.durationMinutes,
  });

  JsonMap toJson() {
    if (target != entireField) {
      throw const FormatException('Irrigation commands require ENTIRE FIELD target.');
    }
    return {
      'target': target,
      if (durationMinutes != null) 'durationMinutes': durationMinutes,
    };
  }
}

class IrrigationResultDto {
  final JsonMap data;

  const IrrigationResultDto(this.data);

  factory IrrigationResultDto.fromJson(Object? json) {
    if (json is! JsonMap) {
      throw const FormatException('Irrigation response is not an object.');
    }
    return IrrigationResultDto(Map<String, dynamic>.from(json));
  }
}
