/// Represents the phenological growth stage of a rice crop under AWD management.
///
/// Different growth stages require distinct water management strategies. For example,
/// during the reproductive stage (flowering/heading), drying stress must be minimized
/// to prevent spikelet sterility and yield loss.
enum CropGrowthStage {
  vegetative,
  reproductive,
  ripening;

  String get label {
    switch (this) {
      case CropGrowthStage.vegetative:
        return 'Vegetative Stage';
      case CropGrowthStage.reproductive:
        return 'Reproductive Stage';
      case CropGrowthStage.ripening:
        return 'Ripening Stage';
    }
  }

  String get description {
    switch (this) {
      case CropGrowthStage.vegetative:
        return 'Tillering and elongation. Standard safe AWD drying down to -15 cm.';
      case CropGrowthStage.reproductive:
        return 'Panicle initiation and flowering. Sensitive to drought stress; avoid severe drying.';
      case CropGrowthStage.ripening:
        return 'Grain filling and terminal field drainage prior to harvest.';
    }
  }

  double get defaultSafeDryThresholdCm {
    switch (this) {
      case CropGrowthStage.vegetative:
        return -15.0;
      case CropGrowthStage.reproductive:
        return -5.0;
      case CropGrowthStage.ripening:
        return -20.0;
    }
  }

  double get defaultRefloodTriggerCm {
    switch (this) {
      case CropGrowthStage.vegetative:
        return -15.0;
      case CropGrowthStage.reproductive:
        return 0.0;
      case CropGrowthStage.ripening:
        return -20.0;
    }
  }

  double get defaultTargetFloodDepthCm {
    switch (this) {
      case CropGrowthStage.vegetative:
        return 5.0;
      case CropGrowthStage.reproductive:
        return 5.0;
      case CropGrowthStage.ripening:
        return 3.0;
    }
  }

  String toJson() => name;

  static CropGrowthStage fromJson(String value) {
    return CropGrowthStage.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => CropGrowthStage.vegetative,
    );
  }
}

