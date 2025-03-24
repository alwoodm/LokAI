import 'package:hive/hive.dart';
import 'package:lokai/models/user_settings.dart';

class SettingsRepository {
  static const String _boxName = 'settings';
  static const String _settingsKey = 'user_settings';
  
  /// Opens the settings box
  Future<Box> _openBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox(_boxName);
    }
    return Hive.box(_boxName);
  }
  
  /// Saves user settings
  Future<void> saveSettings(UserSettings settings) async {
    final box = await _openBox();
    await box.put(_settingsKey, settings);
  }
  
  /// Gets user settings
  Future<UserSettings> getSettings() async {
    final box = await _openBox();
    final settings = box.get(_settingsKey);
    if (settings == null) {
      // Return default settings if none are saved
      return UserSettings();
    }
    return settings;
  }
  
  /// Clears all settings
  Future<void> clearSettings() async {
    final box = await _openBox();
    await box.delete(_settingsKey);
  }
  
  /// Updates a specific setting
  Future<void> updateSetting(String key, dynamic value) async {
    final settings = await getSettings();
    settings.setPreference(key, value);
    await saveSettings(settings);
  }
}
