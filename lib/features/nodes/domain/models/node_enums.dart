/// Formal lifecycle states for physical IoT sensor nodes in AquaSense.
enum NodeLifecycleState {
  /// Node has broadcast join/discovery beacons but is not yet commissioned.
  discovered,

  /// Node has been claimed and is undergoing spatial/datum configuration.
  provisioning,

  /// Node is fully commissioned, assigned to a point, and streaming valid telemetry.
  active,

  /// Node is undergoing calibration, battery swap, or physical repair.
  maintenance,

  /// Node has missed multiple expected heartbeats and is unreachable.
  offline,

  /// Node has been permanently replaced by a newer hardware device at this point.
  replaced,

  /// Node has been retired and permanently removed from field operations.
  decommissioned,
}

/// Transducer / sensing channel types supported by AquaSense sensor nodes.
enum SensorType {
  /// Ultrasonic or hydrostatic water depth inside field observation pipe (cm).
  waterLevelTube,

  /// Frequency domain / capacitive volumetric soil water content (%).
  soilMoistureCapacitive,

  /// Soil temperature sensor (°C).
  soilTemperature,

  /// Ambient air temperature and humidity sensor.
  ambientHumidity,

  /// Internal battery supply voltage monitor (V / mV).
  batteryVoltage,

  /// Soil/water electrical conductivity (salinity probe).
  waterSalinityEc,

  /// Soil reduction-oxidation potential probe (redox mV).
  soilRedox,
}

