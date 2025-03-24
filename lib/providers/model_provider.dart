import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokai/data/repositories/model_repository.dart';
import 'package:lokai/models/ai_model.dart';

// Provider dla repozytorium modeli AI
final modelRepositoryProvider = Provider<ModelRepository>((ref) {
  return ModelRepository();
});

// Provider dla wszystkich modeli AI
final allModelsProvider = FutureProvider<List<AIModel>>((ref) async {
  final repository = ref.watch(modelRepositoryProvider);
  return repository.getAllModels();
});

// Provider dla aktywnego modelu AI
final activeModelProvider = FutureProvider<AIModel?>((ref) async {
  final repository = ref.watch(modelRepositoryProvider);
  return repository.getActiveModel();
});

// Provider dla pojedynczego modelu AI
final modelProvider = FutureProvider.family<AIModel?, String>((ref, id) async {
  final repository = ref.watch(modelRepositoryProvider);
  return repository.getModel(id);
});

// Notifier dla zarządzania modelami AI (CRUD)
class ModelNotifier extends StateNotifier<AsyncValue<List<AIModel>>> {
  final ModelRepository _repository;
  
  ModelNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadModels();
  }
  
  Future<void> loadModels() async {
    state = const AsyncValue.loading();
    try {
      final models = await _repository.getAllModels();
      state = AsyncValue.data(models);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  Future<String> addModel(AIModel model) async {
    final id = await _repository.addModel(model);
    loadModels(); // Odświeżamy listę
    return id;
  }
  
  Future<void> updateModel(AIModel model) async {
    await _repository.updateModel(model);
    loadModels(); // Odświeżamy listę
  }
  
  Future<void> deleteModel(String id) async {
    await _repository.deleteModel(id);
    loadModels(); // Odświeżamy listę
  }
  
  Future<void> setActiveModel(String id) async {
    await _repository.setActiveModel(id);
    loadModels(); // Odświeżamy listę
  }
}

// Provider dla ModelNotifier
final modelNotifierProvider = StateNotifierProvider<ModelNotifier, AsyncValue<List<AIModel>>>((ref) {
  final repository = ref.watch(modelRepositoryProvider);
  return ModelNotifier(repository);
});
