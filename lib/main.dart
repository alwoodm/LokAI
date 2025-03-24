import 'package:flutter/material.dart';
// Usunięto nieużywany import flutter_localizations
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lokai/models/adapters/hive_adapters.dart';
// Generated file once we use the 'generate: true' option and 'flutter gen-l10n'
// import 'package:lokai/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register all adapters
  try {
    HiveAdapters.registerAdapters();
    // Zastąpiono print logowaniem lub komentarzem
    // print('Hive adapters registered successfully');
  } catch (e) {
    // Zastąpiono print logowaniem lub komunikatem do użytkownika
    // print('Error registering Hive adapters: $e');
    debugPrint('Error registering Hive adapters: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LokAI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true, // Enable Material 3
      ),
      // Uncomment these lines when we add actual translations
      // localizationsDelegates: const [
      //   AppLocalizations.delegate,
      //   GlobalMaterialLocalizations.delegate,
      //   GlobalWidgetsLocalizations.delegate,
      //   GlobalCupertinoLocalizations.delegate,
      // ],
      // supportedLocales: const [
      //   Locale('en', ''), // English
      //   Locale('pl', ''), // Polish
      // ],
      home: const MyHomePage(title: 'LokAI - Local AI Assistant'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
