import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lokai/providers/settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsNotifierProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: isDarkMode ? const Color(0xFF343541) : null,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Container(
        color: isDarkMode ? const Color(0xFF343541) : const Color(0xFFF7F7F8),
        child: settingsAsync.when(
          data: (settings) => ListView(
            children: [
              Card(
                margin: const EdgeInsets.all(8),
                color: isDarkMode ? const Color(0xFF3E3F4B) : Colors.white,
                elevation: 0,
                child: ListTile(
                  title: const Text('App Theme'),
                  subtitle: Text(_getThemeModeName(settings.themeMode)),
                  trailing: DropdownButton<ThemeMode>(
                    value: settings.themeMode,
                    onChanged: (ThemeMode? newValue) {
                      if (newValue != null) {
                        ref.read(settingsNotifierProvider.notifier).setThemeMode(newValue);
                      }
                    },
                    dropdownColor: isDarkMode ? const Color(0xFF3E3F4B) : Colors.white,
                    items: const [
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Text('System'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text('Light'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text('Dark'),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, color: Colors.transparent),
              Card(
                margin: const EdgeInsets.all(8),
                color: isDarkMode ? const Color(0xFF3E3F4B) : Colors.white,
                elevation: 0,
                child: SwitchListTile(
                  title: const Text('Voice Input'),
                  subtitle: const Text('Use microphone to enter text'),
                  value: settings.useVoiceInput,
                  onChanged: (bool value) {
                    ref.read(settingsNotifierProvider.notifier).setVoiceInput(value);
                  },
                ),
              ),
              const Divider(height: 1, color: Colors.transparent),
              Card(
                margin: const EdgeInsets.all(8),
                color: isDarkMode ? const Color(0xFF3E3F4B) : Colors.white,
                elevation: 0,
                child: SwitchListTile(
                  title: const Text('Voice Output'),
                  subtitle: const Text('Read AI responses aloud'),
                  value: settings.useVoiceOutput,
                  onChanged: (bool value) {
                    ref.read(settingsNotifierProvider.notifier).setVoiceOutput(value);
                  },
                ),
              ),
              const Divider(height: 1, color: Colors.transparent),
              Card(
                margin: const EdgeInsets.all(8),
                color: isDarkMode ? const Color(0xFF3E3F4B) : Colors.white,
                elevation: 0,
                child: ListTile(
                  title: const Text('Language'),
                  subtitle: Text(_getLanguageName(settings.languageCode)),
                  trailing: DropdownButton<String>(
                    value: settings.languageCode,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        ref.read(settingsNotifierProvider.notifier).setLanguage(newValue);
                      }
                    },
                    dropdownColor: isDarkMode ? const Color(0xFF3E3F4B) : Colors.white,
                    items: const [
                      DropdownMenuItem(
                        value: 'en',
                        child: Text('English'),
                      ),
                      DropdownMenuItem(
                        value: 'pl',
                        child: Text('Polish'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(settingsNotifierProvider.notifier).clearSettings();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Settings have been reset')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[100],
                    foregroundColor: Colors.red[900],
                  ),
                  child: const Text('Reset All Settings'),
                ),
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }
  
  String _getThemeModeName(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }
  
  String _getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'pl':
        return 'Polish';
      default:
        return languageCode;
    }
  }
}
