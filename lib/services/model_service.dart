import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../ai/model_manager.dart';
import '../models/ai_model.dart';
import '../providers/model_provider.dart';

class ModelService {
  final ModelManager _modelManager = ModelManager();
  final Ref _ref;
  
  ModelService(this._ref);

  /// Downloads and installs a model from a repository
  Future<AIModel?> downloadAndInstallModel(
    String url, 
    String modelName, 
    String description, 
    String expectedHash, {
    Function(double)? onProgress,
    String version = '1.0.0',
  }) async {
    try {
      // Check if model already exists
      final exists = await _modelManager.modelExists(modelName, version);
      if (exists) {
        debugPrint('Model $modelName v$version already exists.');
        final path = await _modelManager.getModelPath(modelName, version);
        
        // Create model but don't download again
        final model = AIModel(
          name: modelName,
          description: description,
          size: await File(path).length(),
          filePath: path,
          version: version,
          downloadedAt: DateTime.now(),
        );
        
        // Add to repository
        _ref.read(modelNotifierProvider.notifier).addModel(model);
        return model;
      }
      
      // Download the model
      final modelFile = await _modelManager.downloadModel(
        url, 
        modelName, 
        onProgress: onProgress,
      );
      
      // Verify the model integrity
      final isValid = await _modelManager.verifyModelIntegrity(
        modelFile, 
        expectedHash,
      );
      
      if (!isValid) {
        await modelFile.delete();
        throw Exception('Model verification failed: hash mismatch');
      }
      
      // Install the model
      final model = await _modelManager.installModel(
        modelFile,
        modelName,
        description,
        version: version,
      );
      
      // Add to repository
      _ref.read(modelNotifierProvider.notifier).addModel(model);
      
      return model;
    } catch (e) {
      debugPrint('Error downloading and installing model: $e');
      return null;
    }
  }
  
  /// Uninstalls a model and removes it from the repository
  Future<bool> uninstallModel(AIModel model) async {
    try {
      final success = await _modelManager.uninstallModel(model);
      if (success) {
        _ref.read(modelNotifierProvider.notifier).removeModel(model.id);
      }
      return success;
    } catch (e) {
      debugPrint('Error uninstalling model: $e');
      return false;
    }
  }
  
  /// Gets the total disk space used by all models
  Future<String> getUsedDiskSpaceFormatted() async {
    final bytes = await _modelManager.getUsedDiskSpace();
    return _formatBytes(bytes);
  }
  
  /// Gets the available disk space
  Future<String> getAvailableDiskSpaceFormatted() async {
    final bytes = await _modelManager.getAvailableDiskSpace();
    return _formatBytes(bytes);
  }
  
  /// Formats bytes into a human-readable string
  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = (log(bytes) / log(1024)).floor();
    i = i < suffixes.length ? i : suffixes.length - 1;
    
    return '${(bytes / pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}';
  }
  
  /// Gets a list of all installed models
  Future<List<AIModel>> getInstalledModels() async {
    final models = await _modelManager.getInstalledModels();
    return models;
  }
  
  /// Checks if a model needs to be updated
  Future<bool> checkForModelUpdate(AIModel model, String repositoryUrl) async {
    try {
      final response = await http.get(Uri.parse('$repositoryUrl/models/${model.name}/metadata.json'));
      if (response.statusCode == 200) {
        final metadata = json.decode(response.body);
        final latestVersion = metadata['version'];
        return latestVersion != model.version;
      }
      return false;
    } catch (e) {
      debugPrint('Error checking for model update: $e');
      return false;
    }
  }
}

final modelServiceProvider = Provider<ModelService>((ref) {
  return ModelService(ref);
});
