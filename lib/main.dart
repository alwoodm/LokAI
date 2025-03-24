import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lokai/models/adapters/hive_adapters.dart';
import 'package:lokai/providers/settings_provider.dart';
import 'package:lokai/routing/app_router.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Get application documents directory for Hive storage
  final appDocumentDirectory = await path_provider.getApplicationDocumentsDirectory();
  
  // Initialize Hive with specific path
  await Hive.initFlutter(appDocumentDirectory.path);
  
  // Register all adapters
  try {
    HiveAdapters.registerAdapters();
    debugPrint('Hive adapters registered successfully');
  } catch (e) {
    debugPrint('Error registering Hive adapters: $e');
  }
  
  // Ensure boxes are open at app start
  await _openHiveBoxes();
  
  runApp(const ProviderScope(child: MyApp()));
}

/// Open all Hive boxes at application start
Future<void> _openHiveBoxes() async {
  await Hive.openBox('settings');
  await Hive.openBox<dynamic>('conversations');
  await Hive.openBox<dynamic>('messages');
  await Hive.openBox<dynamic>('ai_models');
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obserwujemy ustawienia użytkownika aby reagować na zmiany motywu
    final settingsAsync = ref.watch(settingsNotifierProvider);
    
    return settingsAsync.when(
      data: (settings) {
        return MaterialApp.router(
          title: 'LokAI',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          themeMode: settings.themeMode,
          routerConfig: appRouter,
          debugShowCheckedModeBanner: false,
        );
      },
      loading: () => MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error: (error, stackTrace) => MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Błąd inicjalizacji: $error'),
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Welcome to LokAI!'),
            const SizedBox(height: 20),
            const Text('Your local AI assistant on your mobile device'),
            const SizedBox(height: 40),
            const Text('Test counter (to be removed):'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
