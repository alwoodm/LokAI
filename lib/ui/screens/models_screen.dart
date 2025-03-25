import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lokai/models/ai_model.dart';
import 'package:lokai/services/model_service.dart';
import 'package:lokai/utils/model_test_helper.dart';
import 'package:lokai/utils/model_inference_helper.dart';

class ModelsScreen extends ConsumerWidget {
  // Parameter to control bottom navigation visibility
  final bool showBottomNav;
  
  const ModelsScreen({
    super.key,
    this.showBottomNav = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final modelService = ref.watch(modelServiceProvider);
    
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
        actions: [
          IconButton(
            icon: const Icon(Icons.memory),
            onPressed: () => _checkGpuAvailability(context, ref),
            tooltip: 'Check GPU',
          ),
          IconButton(
            icon: const Icon(Icons.storage),
            onPressed: () => ModelTestHelper(ref).showStorageInfo(context),
            tooltip: 'Storage Info',
          ),
        ],
      ),
      body: FutureBuilder<List<AIModel>>(
        future: modelService.getInstalledModels(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          final models = snapshot.data ?? [];
          
          if (models.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.model_training, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No models installed yet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add a model using the button below',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _downloadTestModel(context, ref),
                    icon: const Icon(Icons.download),
                    label: const Text('Download Test Model'),
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            itemCount: models.length,
            padding: const EdgeInsets.all(16.0),
            itemBuilder: (context, index) {
              final model = models[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                child: ListTile(
                  title: Text(model.name),
                  subtitle: Text('${model.description}\nSize: ${model.formattedSize}'),
                  isThreeLine: true,
                  leading: const CircleAvatar(
                    child: Icon(Icons.smart_toy),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.play_arrow),
                        tooltip: 'Test model',
                        onPressed: () => _testModel(context, ref, model),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        tooltip: 'Delete model',
                        onPressed: () => _uninstallModel(context, ref, model),
                      ),
                    ],
                  ),
                  onTap: () {
                    // Model details or activation
                    _showModelDetails(context, model);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _downloadTestModel(context, ref),
        tooltip: 'Download test model',
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
  
  Future<void> _downloadTestModel(BuildContext context, WidgetRef ref) async {
    await ModelTestHelper(ref).downloadTestModel(
      context: context,
      modelName: 'WhisperTest',
      description: 'Tiny English Whisper model for testing',
    );
  }
  
  Future<void> _uninstallModel(BuildContext context, WidgetRef ref, AIModel model) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Uninstall Model'),
        content: Text('Are you sure you want to uninstall ${model.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Uninstall'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      final modelService = ref.read(modelServiceProvider);
      final success = await modelService.uninstallModel(model);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Model ${model.name} uninstalled successfully' : 'Failed to uninstall model',
            ),
          ),
        );
      }
    }
  }
  
  void _showModelDetails(BuildContext context, AIModel model) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(model.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Description: ${model.description}'),
            const SizedBox(height: 8),
            Text('Size: ${model.formattedSize}'),
            const SizedBox(height: 8),
            Text('Version: ${model.version}'),
            const SizedBox(height: 8),
            Text('Location: ${model.filePath}'),
            const SizedBox(height: 8),
            Text('Downloaded: ${model.downloadedAt?.toString() ?? 'Unknown'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _testModel(BuildContext context, WidgetRef ref, AIModel model) async {
    final inferenceHelper = ModelInferenceHelper(ref);
    await inferenceHelper.testModelInference(context, model);
  }
  
  Future<void> _checkGpuAvailability(BuildContext context, WidgetRef ref) async {
    final inferenceHelper = ModelInferenceHelper(ref);
    await inferenceHelper.isGpuAvailable(context);
  }
}
