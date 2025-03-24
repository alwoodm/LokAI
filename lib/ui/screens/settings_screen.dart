import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lokai/providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsNotifierProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ustawienia'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: settingsAsync.when(
        data: (settings) => ListView(
          children: [
            ListTile(
              title: const Text('Motyw aplikacji'),
              subtitle: Text(_getThemeModeName(settings.themeMode)),
              trailing: DropdownButton<ThemeMode>(
                value: settings.themeMode,
                onChanged: (ThemeMode? newValue) {
                  if (newValue != null) {
                    ref.read(settingsNotifierProvider.notifier).setThemeMode(newValue);
                  }
                },
                items: const [
                  DropdownMenuItem(
                    value: ThemeMode.system,
                    child: Text('Systemowy'),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Text('Jasny'),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.dark,
                    child: Text('Ciemny'),
                  ),
                ],
              ),
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Wejście głosowe'),
              subtitle: const Text('Używaj mikrofonu do wprowadzania tekstu'),
              value: settings.useVoiceInput,
              onChanged: (bool value) {
                ref.read(settingsNotifierProvider.notifier).setVoiceInput(value);
              },
            ),
            SwitchListTile(
              title: const Text('Wyjście głosowe'),
              subtitle: const Text('Czytaj odpowiedzi AI na głos'),
              value: settings.useVoiceOutput,
              onChanged: (bool value) {
                ref.read(settingsNotifierProvider.notifier).setVoiceOutput(value);
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Język'),
              subtitle: Text(_getLanguageName(settings.languageCode)),
              trailing: DropdownButton<String>(
                value: settings.languageCode,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    ref.read(settingsNotifierProvider.notifier).setLanguage(newValue);
                  }
                },
                items: const [
                  DropdownMenuItem(
                    value: 'en',
                    child: Text('English'),
                  ),
                  DropdownMenuItem(
                    value: 'pl',
                    child: Text('Polski'),
                  ),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  ref.read(settingsNotifierProvider.notifier).clearSettings();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ustawienia zostały zresetowane')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[100],
                  foregroundColor: Colors.red[900],
                ),
                child: const Text('Zresetuj wszystkie ustawienia'),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Błąd: $error')),
      ),
    );
  }
  
  String _getThemeModeName(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.system:
        return 'Systemowy';
      case ThemeMode.light:
        return 'Jasny';
      case ThemeMode.dark:
        return 'Ciemny';
    }
  }
  
  String _getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'pl':
        return 'Polski';
      default:
        return languageCode;
    }
  }
}
