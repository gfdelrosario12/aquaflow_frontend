/// Phenological growth stages of rice determining active AWD threshold tolerance.
enum CropStage {
  /// Land preparation, soaking, and leveling phase (saturated).
  landPrep,

  /// Seedling nursery or direct seeded emergence.
  seedling,

  /// Early tillering and vegetative growth (optimal for AWD drying cycles).
  vegetativeTillering,

  /// Panicle initiation to booting (critical sensitivity: no severe drying).
  panicleInitiation,

  /// Flowering, pollination, and heading (standing water required).
  floweringHeading,

  /// Grain filling and milk-to-dough stage (safe AWD drying).
  grainFilling,

  /// Terminal drainage prior to harvest (drying field for combine harvesters).
  ripeningHarvest,
}

/// Represents the top-level agricultural field / paddy deployment boundary.
class Field {
  final String id;
  final String name;
  final String? description;
  final double areaSquareMeters;
  final String soilType;
  final CropStage activeCropStage;
  final String awdProfileId;
  final String? centralControllerId;
  final List<Map<String, double>> boundaryCoordinates;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? metadata;

  const Field({
    required this.id,
    required this.name,
    this.description,
    this.areaSquareMeters = 10000.0,
    this.soilType = 'Clay Loam',
    this.activeCropStage = CropStage.vegetativeTillering,
    this.awdProfileId = 'awd_standard_vegetative',
    this.centralControllerId,
    this.boundaryCoordinates = const [],
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
  });

  Field copyWith({
    String? id,
    String? name,
    String? description,
    double? areaSquareMeters,
    String? soilType,
    CropStage? activeCropStage,
    String? awdProfileId,
    String? centralControllerId,
    List<Map<String, double>>? boundaryCoordinates,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Field(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      areaSquareMeters: areaSquareMeters ?? this.areaSquareMeters,
      soilType: soilType ?? this.soilType,
      activeCropStage: activeCropStage ?? this.activeCropStage,
      awdProfileId: awdProfileId ?? this.awdProfileId,
      centralControllerId: centralControllerId ?? this.centralControllerId,
      boundaryCoordinates: boundaryCoordinates ?? this.boundaryCoordinates,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (description != null) 'description': description,
        'areaSquareMeters': areaSquareMeters,
        'soilType': soilType,
        'activeCropStage': activeCropStage.name,
        'awdProfileId': awdProfileId,
        if (centralControllerId != null)
          'centralControllerId': centralControllerId,
        'boundaryCoordinates': boundaryCoordinates,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        if (metadata != null) 'metadata': metadata,
      };

  factory Field.fromJson(Map<String, dynamic> json) {
    return Field(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      areaSquareMeters:
          (json['areaSquareMeters'] as num?)?.toDouble() ?? 10000.0,
      soilType: json['soilType'] as String? ?? 'Clay Loam',
      activeCropStage: CropStage.values.firstWhere(
        (e) => e.name == json['activeCropStage'],
        orElse: () => CropStage.vegetativeTillering,
      ),
      awdProfileId: json['awdProfileId'] as String? ?? 'awd_standard_vegetative',
      centralControllerId: json['centralControllerId'] as String?,
      boundaryCoordinates: (json['boundaryCoordinates'] as List<dynamic>?)
              ?.map((item) => (item as Map<String, dynamic>)
                  .map((k, v) => MapEntry(k, (v as num).toDouble())))
              .toList() ??
          const [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

