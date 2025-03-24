import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lokai/models/ai_model.dart';
import 'package:lokai/providers/model_provider.dart';

class ModelsScreen extends ConsumerWidget {
  // Parameter to control bottom navigation visibility
  final bool showBottomNav;
  
  const ModelsScreen({
    super.key,
    this.showBottomNav = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modelsAsync = ref.watch(allModelsProvider);
    final activeModelAsync = ref.watch(activeModelProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Models'),
        backgroundColor: isDarkMode ? const Color(0xFF343541) : null,
        // Remove back button in the shell route
        automaticallyImplyLeading: !showBottomNav,
        leading: !showBottomNav ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ) : null,
      ),
      body: Container(
        color: isDarkMode ? const Color(0xFF343541) : const Color(0xFFF7F7F8),
        child: modelsAsync.when(
          data: (models) {
            if (models.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.model_training,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No models available',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () => _addDemoModel(ref),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Add sample model'),
                    ),
                  ],
                ),
              );
            }
            
            return ListView.builder(
              itemCount: models.length,
              padding: const EdgeInsets.all(8),
              itemBuilder: (context, index) {
                final model = models[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  elevation: 0,
                  color: isDarkMode ? const Color(0xFF3E3F4B) : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                model.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Colors.white : Colors.black,
                                ),
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
                        Text(
                          model.description,
                          style: TextStyle(
                            color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Size: ${model.formattedSize}',
                              style: TextStyle(
                                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                            Text(
                              'Version: ${model.version}',
                              style: TextStyle(
                                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                ref.read(modelNotifierProvider.notifier).deleteModel(model.id);
                              },
                              child: const Text('Delete'),
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
          error: (error, stack) => Center(child: Text('Error: $error')),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addDemoModel(ref),
        tooltip: 'Add model',
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      // Remove the bottom navigation bar as it's already provided by the ShellRoute
    );
  }
  
  void _addDemoModel(WidgetRef ref) {
    final model = AIModel(
      name: 'DemoModel ${DateTime.now().millisecondsSinceEpoch % 1000}',
      description: 'Sample model for testing purposes',
      size: 250 * 1024 * 1024, // 250 MB
      filePath: '/storage/models/demo.bin',
      version: '1.0.0',
    );
    
    ref.read(modelNotifierProvider.notifier).addModel(model);
  }
}
