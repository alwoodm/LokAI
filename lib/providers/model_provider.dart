import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokai/data/repositories/model_repository.dart';
import 'package:lokai/models/ai_model.dart';

// Provider dla repozytorium modeli AI
final modelRepositoryProvider = Provider<ModelRepository>((ref) {
  return ModelRepository();
});

// Provider dla wszystkich modeli AI
final allModelsProvider = Provider<List<AIModel>>((ref) {
  return ref.watch(modelNotifierProvider);
});

// Provider dla aktywnego modelu AI
final activeModelProvider = Provider<AIModel?>((ref) {
  final models = ref.watch(modelNotifierProvider);
  return models.isNotEmpty ? models.first : null;
});

// Provider dla pojedynczego modelu AI
final modelProvider = FutureProvider.family<AIModel?, String>((ref, id) async {
  final repository = ref.watch(modelRepositoryProvider);
  return repository.getModel(id);
});

// Notifier dla zarządzania modelami AI (CRUD)
class ModelNotifier extends StateNotifier<List<AIModel>> {
  ModelNotifier() : super([]);
  
  void addModel(AIModel model) {
    // Check if model already exists
    final modelIndex = state.indexWhere((m) => m.id == model.id);
    if (modelIndex >= 0) {
      // Update existing model
      final updatedModels = [...state];
      updatedModels[modelIndex] = model;
      state = updatedModels;
    } else {
      // Add new model
      state = [...state, model];
    }
  }
  
  void removeModel(String modelId) {
    state = state.where((model) => model.id != modelId).toList();
  }
  
  void setActiveModel(String modelId) {
    // Implementation would depend on how you track active models
    // This is just a placeholder
  }
}

// Provider dla ModelNotifier
final modelNotifierProvider = StateNotifierProvider<ModelNotifier, List<AIModel>>((ref) {
  return ModelNotifier();
});
