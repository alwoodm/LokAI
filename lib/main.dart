import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    debugPrint('Hive adapters registered successfully');
  } catch (e) {
    debugPrint('Error registering Hive adapters: $e');
  }
  
  // Owijamy aplikację w ProviderScope, aby udostępnić dostawców Riverpod
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
