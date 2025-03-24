import 'package:hive/hive.dart';
import 'package:lokai/models/ai_model.dart';

class ModelRepository {
  static const String _boxName = 'ai_models';
  static Box? _box;
  
  /// Opens the AI models box
  Future<Box> _openBox() async {
    if (_box != null && _box!.isOpen) {
      return _box!;
    }
    
    if (Hive.isBoxOpen(_boxName)) {
      _box = Hive.box(_boxName);
      return _box!;
    }
    
    _box = await Hive.openBox(_boxName);
    return _box!;
  }
  
  /// Adds a new AI model
  Future<String> addModel(AIModel model) async {
    final box = await _openBox();
    await box.put(model.id, model);
    return model.id;
  }
  
  /// Gets a model by id
  Future<AIModel?> getModel(String id) async {
    final box = await _openBox();
    final dynamic result = box.get(id);
    if (result is AIModel) {
      return result;
    }
    return null;
  }
  
  /// Gets all models
  Future<List<AIModel>> getAllModels() async {
    final box = await _openBox();
    return box.values.whereType<AIModel>().toList();
  }
  
  /// Updates a model
  Future<void> updateModel(AIModel model) async {
    final box = await _openBox();
    await box.put(model.id, model);
  }
  
  /// Deletes a model
  Future<void> deleteModel(String id) async {
    final box = await _openBox();
    await box.delete(id);
  }
  
  /// Gets the active model
  Future<AIModel?> getActiveModel() async {
    final box = await _openBox();
    final models = box.values
        .whereType<AIModel>()
        .where((model) => model.isActive)
        .toList();
    return models.isNotEmpty ? models.first : null;
  }
  
  /// Sets a model as active and deactivates all others
  Future<void> setActiveModel(String id) async {
    final box = await _openBox();
    final models = box.values.toList();
    
    for (final model in models) {
      model.isActive = model.id == id;
      await box.put(model.id, model);
    }
  }
}
