import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class UserSettings {
  final Map<String, dynamic> preferences;
  String? selectedModelId;
  String themeModeString;
  bool useVoiceInput;
  bool useVoiceOutput;
  String languageCode;

  /// Creates a new UserSettings instance with the given parameters.
  UserSettings({
    Map<String, dynamic>? preferences,
    this.selectedModelId,
    ThemeMode themeMode = ThemeMode.system,
    this.useVoiceInput = false,
    this.useVoiceOutput = false,
    this.languageCode = 'en',
  }) : 
    preferences = preferences ?? {},
    themeModeString = _themeModeToString(themeMode);
  
  /// Creates UserSettings from a JSON map.
  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      preferences: json['preferences'] as Map<String, dynamic>? ?? {},
      selectedModelId: json['selectedModelId'] as String?,
      themeMode: _themeModeFromString(json['themeMode'] as String?),
      useVoiceInput: json['useVoiceInput'] as bool? ?? false,
      useVoiceOutput: json['useVoiceOutput'] as bool? ?? false,
      languageCode: json['languageCode'] as String? ?? 'en',
    );
  }
  
  /// Converts the UserSettings to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'preferences': preferences,
      'selectedModelId': selectedModelId,
      'themeMode': themeModeString,
      'useVoiceInput': useVoiceInput,
      'useVoiceOutput': useVoiceOutput,
      'languageCode': languageCode,
    };
  }
  
  /// Gets the theme mode from the stored string
  ThemeMode get themeMode => _themeModeFromString(themeModeString);
  
  /// Sets the theme mode by updating the string
  set themeMode(ThemeMode mode) {
    themeModeString = _themeModeToString(mode);
  }
  
  /// Converts a string to ThemeMode.
  static ThemeMode _themeModeFromString(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
  
  /// Converts ThemeMode to string.
  static String _themeModeToString(ThemeMode mode) {
    return mode.toString().split('.').last;
  }
  
  /// Returns a copy of these settings with the specified fields replaced.
  UserSettings copyWith({
    Map<String, dynamic>? preferences,
    String? selectedModelId,
    ThemeMode? themeMode,
    bool? useVoiceInput,
    bool? useVoiceOutput,
    String? languageCode,
  }) {
    return UserSettings(
      preferences: preferences ?? Map.from(this.preferences),
      selectedModelId: selectedModelId ?? this.selectedModelId,
      themeMode: themeMode ?? this.themeMode,
      useVoiceInput: useVoiceInput ?? this.useVoiceInput,
      useVoiceOutput: useVoiceOutput ?? this.useVoiceOutput,
      languageCode: languageCode ?? this.languageCode,
    );
  }
  
  /// Sets a preference value.
  void setPreference(String key, dynamic value) {
    preferences[key] = value;
  }
  
  /// Gets a preference value.
  T? getPreference<T>(String key, {T? defaultValue}) {
    return preferences[key] as T? ?? defaultValue;
  }
  
  @override
  String toString() {
    return 'UserSettings(selectedModelId: $selectedModelId, themeMode: $themeMode, languageCode: $languageCode)';
  }
}

class UserSettingsAdapter extends TypeAdapter<UserSettings> {
  @override
  final int typeId = 4;

  @override
  UserSettings read(BinaryReader reader) {
    final int length = reader.readInt();
    final Map<String, dynamic> preferences = {};
    
    for (var i = 0; i < length; i++) {
      final key = reader.readString();
      final value = reader.read();
      preferences[key] = value;
    }
    
    final selectedModelId = reader.readString();
    final themeModeString = reader.readString();
    final useVoiceInput = reader.readBool();
    final useVoiceOutput = reader.readBool();
    final languageCode = reader.readString();
    
    return UserSettings(
      preferences: preferences,
      selectedModelId: selectedModelId.isEmpty ? null : selectedModelId,
      themeMode: UserSettings._themeModeFromString(themeModeString),
      useVoiceInput: useVoiceInput,
      useVoiceOutput: useVoiceOutput,
      languageCode: languageCode,
    );
  }

  @override
  void write(BinaryWriter writer, UserSettings obj) {
    writer.writeInt(obj.preferences.length);
    obj.preferences.forEach((key, value) {
      writer.writeString(key);
      writer.write(value);
    });
    
    writer.writeString(obj.selectedModelId ?? '');
    writer.writeString(obj.themeModeString);
    writer.writeBool(obj.useVoiceInput);
    writer.writeBool(obj.useVoiceOutput);
    writer.writeString(obj.languageCode);
  }
}
