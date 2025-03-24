import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lokai/models/ai_model.dart';
import 'package:lokai/providers/model_provider.dart';

class ModelsScreen extends ConsumerWidget {
  const ModelsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modelsAsync = ref.watch(allModelsProvider);
    final activeModelAsync = ref.watch(activeModelProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biblioteka modeli'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: modelsAsync.when(
        data: (models) {
          if (models.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Brak dostępnych modeli'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _addDemoModel(ref),
                    child: const Text('Dodaj przykładowy model'),
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            itemCount: models.length,
            itemBuilder: (context, index) {
              final model = models[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              model.name,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          activeModelAsync.when(
                            data: (activeModel) => Radio<bool>(
                              value: true,
                              groupValue: activeModel?.id == model.id,
                              onChanged: (_) {
                                ref.read(modelNotifierProvider.notifier).setActiveModel(model.id);
                              },
                            ),
                            loading: () => const SizedBox.square(dimension: 24),
                            error: (_, __) => const Icon(Icons.error, color: Colors.red),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(model.description),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Rozmiar: ${model.formattedSize}'),
                          Text('Wersja: ${model.version}'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              ref.read(modelNotifierProvider.notifier).deleteModel(model.id);
                            },
                            child: const Text('Usuń'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Błąd: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addDemoModel(ref),
        tooltip: 'Dodaj model',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1: // Już jesteśmy na stronie modeli
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Główna',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.model_training),
            label: 'Modele',
          ),
        ],
      ),
    );
  }
  
  void _addDemoModel(WidgetRef ref) {
    final model = AIModel(
      name: 'DemoModel ${DateTime.now().millisecondsSinceEpoch % 1000}',
      description: 'Przykładowy model do testów',
      size: 250 * 1024 * 1024, // 250 MB
      filePath: '/storage/models/demo.bin',
      version: '1.0.0',
    );
    
    ref.read(modelNotifierProvider.notifier).addModel(model);
  }
}
