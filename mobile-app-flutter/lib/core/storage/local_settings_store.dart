import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class LocalSettingsStore {
  static const String scannerFinishCharactersKey = 'SCANNERFINISHARACTERS';
  static const String backgroundSyncTimerKey = 'BACKGROUNDSYNCTIMER';
  static const String saveBackgroundFileKey = 'savephotoBackground';
  static const String installationIdKey = 'gc_installation_id';

  SharedPreferences? _preferences;

  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  SharedPreferences get _prefs {
    final SharedPreferences? prefs = _preferences;
    if (prefs == null) {
      throw StateError('LocalSettingsStore.init() must be called before use.');
    }
    return prefs;
  }

  String get scannerFinishCharacters =>
      _prefs.getString(scannerFinishCharactersKey) ?? '0x0D0A';

  Future<void> setScannerFinishCharacters(String value) async {
    await _prefs.setString(scannerFinishCharactersKey, value);
  }

  String get backgroundSyncTimer =>
      _prefs.getString(backgroundSyncTimerKey) ?? '600';

  Future<void> setBackgroundSyncTimer(String value) async {
    await _prefs.setString(backgroundSyncTimerKey, value);
  }

  bool get saveBackgroundFile => _prefs.getBool(saveBackgroundFileKey) ?? false;

  Future<void> setSaveBackgroundFile(bool value) async {
    await _prefs.setBool(saveBackgroundFileKey, value);
  }

  Future<String> getOrCreateInstallationId() async {
    final String? current = _prefs.getString(installationIdKey);
    if (current != null && current.isNotEmpty) {
      return current;
    }
    final String created = const Uuid().v4();
    await _prefs.setString(installationIdKey, created);
    return created;
  }
}
