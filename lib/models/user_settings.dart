import 'package:flutter/material.dart';

/// Represents user preferences and settings.
class UserSettings {
  /// General preferences map for any user settings
  final Map<String, dynamic> preferences;
  
  /// ID of the currently selected AI model
  String? selectedModelId;
  
  /// Current theme mode (light, dark, system)
  ThemeMode themeMode;
  
  /// Whether to use voice input
  bool useVoiceInput;
  
  /// Whether to use voice output
  bool useVoiceOutput;
  
  /// System language code (e.g., 'en', 'pl')
  String languageCode;

  /// Creates a new UserSettings instance with the given parameters.
  UserSettings({
    Map<String, dynamic>? preferences,
    this.selectedModelId,
    this.themeMode = ThemeMode.system,
    this.useVoiceInput = false,
    this.useVoiceOutput = false,
    this.languageCode = 'en',
  }) : preferences = preferences ?? {};
  
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
      'themeMode': themeMode.toString().split('.').last,
      'useVoiceInput': useVoiceInput,
      'useVoiceOutput': useVoiceOutput,
      'languageCode': languageCode,
    };
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
