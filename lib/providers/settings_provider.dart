import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokai/data/repositories/settings_repository.dart';
import 'package:lokai/models/user_settings.dart';

// Provider dla repozytorium ustawień
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

// Provider dla ustawień użytkownika
final userSettingsProvider = FutureProvider<UserSettings>((ref) async {
  final repository = ref.watch(settingsRepositoryProvider);
  return repository.getSettings();
});

// Notifier dla zarządzania ustawieniami
class SettingsNotifier extends StateNotifier<AsyncValue<UserSettings>> {
  final SettingsRepository _repository;
  
  SettingsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadSettings();
  }
  
  Future<void> loadSettings() async {
    state = const AsyncValue.loading();
    try {
      final settings = await _repository.getSettings();
      state = AsyncValue.data(settings);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  Future<void> saveSettings(UserSettings settings) async {
    await _repository.saveSettings(settings);
    loadSettings(); // Odświeżamy stan
  }
  
  Future<void> updateSetting(String key, dynamic value) async {
    await _repository.updateSetting(key, value);
    loadSettings(); // Odświeżamy stan
  }
  
  Future<void> clearSettings() async {
    await _repository.clearSettings();
    loadSettings(); // Odświeżamy stan
  }
  
  Future<void> setSelectedModel(String? modelId) async {
    final currentSettings = state.value ?? await _repository.getSettings();
    final newSettings = currentSettings.copyWith(selectedModelId: modelId);
    await _repository.saveSettings(newSettings);
    loadSettings(); // Odświeżamy stan
  }
  
  Future<void> setThemeMode(ThemeMode themeMode) async {
    final currentSettings = state.value ?? await _repository.getSettings();
    final newSettings = currentSettings.copyWith(themeMode: themeMode);
    await _repository.saveSettings(newSettings);
    loadSettings(); // Odświeżamy stan
  }
  
  Future<void> setVoiceInput(bool enabled) async {
    final currentSettings = state.value ?? await _repository.getSettings();
    final newSettings = currentSettings.copyWith(useVoiceInput: enabled);
    await _repository.saveSettings(newSettings);
    loadSettings(); // Odświeżamy stan
  }
  
  Future<void> setVoiceOutput(bool enabled) async {
    final currentSettings = state.value ?? await _repository.getSettings();
    final newSettings = currentSettings.copyWith(useVoiceOutput: enabled);
    await _repository.saveSettings(newSettings);
    loadSettings(); // Odświeżamy stan
  }
  
  Future<void> setLanguage(String languageCode) async {
    final currentSettings = state.value ?? await _repository.getSettings();
    final newSettings = currentSettings.copyWith(languageCode: languageCode);
    await _repository.saveSettings(newSettings);
    loadSettings(); // Odświeżamy stan
  }
}

// Provider dla SettingsNotifier
final settingsNotifierProvider = StateNotifierProvider<SettingsNotifier, AsyncValue<UserSettings>>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return SettingsNotifier(repository);
});
