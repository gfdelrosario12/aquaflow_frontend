import '../../domain/models/settings_models.dart';

abstract class SettingsRepository {
  Future<SettingsSnapshot> load();
  Future<void> save(SettingsSnapshot settings);
}

class LocalSettingsRepository implements SettingsRepository {
  SettingsSnapshot _settings;
  final Duration latency;
  bool failLoad;
  bool failSave;

  LocalSettingsRepository({
    SettingsSnapshot? initialSettings,
    this.latency = const Duration(milliseconds: 120),
    this.failLoad = false,
    this.failSave = false,
  }) : _settings = initialSettings ?? SettingsSnapshot.defaults();

  @override
  Future<SettingsSnapshot> load() async {
    await Future<void>.delayed(latency);
    if (failLoad) {
      throw const SettingsStorageException('Unable to load saved settings.');
    }
    return _settings;
  }

  @override
  Future<void> save(SettingsSnapshot settings) async {
    await Future<void>.delayed(latency);
    if (failSave) {
      throw const SettingsStorageException('Unable to save settings.');
    }
    _settings = settings;
  }
}

class SettingsStorageException implements Exception {
  final String message;

  const SettingsStorageException(this.message);

  @override
  String toString() => message;
}
