/// Dual representation of physical node positioning
class SpatialCoordinates {
  /// Global WGS84 coordinates
  final double? latitude;
  final double? longitude;

  /// Local Cartesian coordinates in meters relative to field origin (0,0)
  final double? localX;
  final double? localY;

  /// Optional elevation in meters above sea level
  final double? elevationMeters;

  const SpatialCoordinates({
    this.latitude,
    this.longitude,
    this.localX,
    this.localY,
    this.elevationMeters,
  });

  bool get hasGeoCoordinates => latitude != null && longitude != null;
  bool get hasLocalCoordinates => localX != null && localY != null;
  bool get hasAnyCoordinates => hasGeoCoordinates || hasLocalCoordinates;

  SpatialCoordinates copyWith({
    double? latitude,
    double? longitude,
    double? localX,
    double? localY,
    double? elevationMeters,
  }) {
    return SpatialCoordinates(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      localX: localX ?? this.localX,
      localY: localY ?? this.localY,
      elevationMeters: elevationMeters ?? this.elevationMeters,
    );
  }

  Map<String, dynamic> toJson() => {
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (localX != null) 'localX': localX,
        if (localY != null) 'localY': localY,
        if (elevationMeters != null) 'elevationMeters': elevationMeters,
      };

  factory SpatialCoordinates.fromJson(Map<String, dynamic> json) {
    return SpatialCoordinates(
      latitude: json['latitude'] == null
          ? null
          : double.tryParse(json['latitude'].toString()),
      longitude: json['longitude'] == null
          ? null
          : double.tryParse(json['longitude'].toString()),
      localX: json['localX'] == null
          ? null
          : double.tryParse(json['localX'].toString()),
      localY: json['localY'] == null
          ? null
          : double.tryParse(json['localY'].toString()),
      elevationMeters: json['elevationMeters'] == null
          ? null
          : double.tryParse(json['elevationMeters'].toString()),
    );
  }
}

