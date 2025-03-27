import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:disk_space/disk_space.dart';
import 'package:lokai/models/ai_model.dart';
import 'package:lokai/data/repositories/model_repository.dart';

/// Manages downloading, installing, and lifecycle of AI models
class ModelManager {
  final ModelRepository _repository;
  final http.Client _httpClient;
  
  /// Creates a model manager with the given repository
  ModelManager(this._repository, {http.Client? httpClient}) 
      : _httpClient = httpClient ?? http.Client();
  
  /// Gets the directory where models will be stored
  Future<Directory> get _modelsDirectory async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final modelsDir = Directory('${appDocDir.path}/models');
    if (!await modelsDir.exists()) {
      await modelsDir.create(recursive: true);
    }
    return modelsDir;
  }
  
  /// Downloads a model from a URL with progress tracking
  Stream<DownloadProgress> downloadModelWithProgress(String url, String fileName) async* {
    try {
      final request = http.Request('GET', Uri.parse(url));
      final response = await _httpClient.send(request);
      
      if (response.statusCode != 200) {
        throw Exception('Failed to download model: ${response.statusCode}');
      }
      
      final contentLength = response.contentLength ?? 0;
      
      final modelsDir = await _modelsDirectory;
      final file = File('${modelsDir.path}/$fileName');
      
      int downloaded = 0;
      final sink = file.openWrite();
      
      await for (final chunk in response.stream) {
        sink.add(chunk);
        downloaded += chunk.length;
        
        if (contentLength > 0) {
          yield DownloadProgress(
            file: file,
            progress: downloaded / contentLength,
            downloaded: downloaded,
            total: contentLength,
          );
        }
      }
      
      await sink.close();
      yield DownloadProgress(
        file: file,
        progress: 1.0,
        downloaded: downloaded,
        total: contentLength,
      );
    } catch (e) {
      throw Exception('Error downloading model with progress: $e');
    }
  }
  
  /// Calculates SHA-256 checksum of a file
  Future<String> calculateChecksum(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final digest = sha256.convert(bytes);
      return digest.toString();
    } catch (e) {
      throw Exception('Error calculating checksum: $e');
    }
  }
  
  /// Verifies model file against expected checksum
  Future<bool> verifyModel(File file, String expectedChecksum) async {
    final checksum = await calculateChecksum(file);
    return checksum == expectedChecksum;
  }
  
  /// Downloads and installs a model, adding it to the repository
  Future<AIModel> installModel({
    required String url,
    required String name,
    required String description,
    required String version,
    required String expectedChecksum,
    Function(DownloadProgress)? onProgress,
  }) async {
    try {
      // Create a unique filename based on model name and version
      final fileName = '${name.replaceAll(' ', '_').toLowerCase()}_$version.bin';
      
      // Download the model with progress tracking
      File? file;
      await for (final progress in downloadModelWithProgress(url, fileName)) {
        if (onProgress != null) {
          onProgress(progress);
        }
        file = progress.file;
      }
      
      if (file == null) {
        throw Exception('Model download failed: file is null');
      }
      
      // Verify the downloaded file
      final isValid = await verifyModel(file, expectedChecksum);
      if (!isValid) {
        // Delete the file if verification fails
        await file.delete();
        throw Exception('Model verification failed: checksum mismatch');
      }
      
      // Get file size
      final fileSize = await file.length();
      
      // Create AIModel object
      final model = AIModel(
        name: name,
        description: description,
        size: fileSize,
        filePath: file.path,
        version: version,
      );
      
      // Add model to repository
      final id = await _repository.addModel(model);
      
      // Return the model with its ID
      return AIModel(
        id: id,
        name: name,
        description: description,
        size: fileSize,
        filePath: file.path,
        version: version,
        downloadedAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Error installing model: $e');
    }
  }
  
  /// Activates a model (set as active)
  Future<void> activateModel(String id) async {
    await _repository.setActiveModel(id);
  }
  
  /// Deletes a model and its file
  Future<void> deleteModel(String id) async {
    try {
      // Get model from repository
      final model = await _repository.getModel(id);
      
      if (model == null) {
        throw Exception('Model not found: $id');
      }
      
      // Delete the file
      final file = File(model.filePath);
      if (await file.exists()) {
        await file.delete();
      }
      
      // Delete from repository
      await _repository.deleteModel(id);
    } catch (e) {
      throw Exception('Error deleting model: $e');
    }
  }
  
  /// Updates a model to a newer version
  Future<AIModel> updateModel(String id, {
    required String url,
    required String version,
    required String expectedChecksum,
    Function(DownloadProgress)? onProgress,
  }) async {
    try {
      // Get the existing model
      final existingModel = await _repository.getModel(id);
      
      if (existingModel == null) {
        throw Exception('Model not found: $id');
      }
      
      // Create new filename for updated model
      final fileName = '${existingModel.name.replaceAll(' ', '_').toLowerCase()}_$version.bin';
      
      // Download the updated model
      File? file;
      await for (final progress in downloadModelWithProgress(url, fileName)) {
        if (onProgress != null) {
          onProgress(progress);
        }
        file = progress.file;
      }
      
      if (file == null) {
        throw Exception('Model update failed: file is null');
      }
      
      // Verify the downloaded file
      final isValid = await verifyModel(file, expectedChecksum);
      if (!isValid) {
        // Delete the file if verification fails
        await file.delete();
        throw Exception('Model update verification failed: checksum mismatch');
      }
      
      // Get file size
      final fileSize = await file.length();
      
      // Delete the old file if it's different
      if (existingModel.filePath != file.path) {
        final oldFile = File(existingModel.filePath);
        if (await oldFile.exists()) {
          await oldFile.delete();
        }
      }
      
      // Create updated model
      final updatedModel = AIModel(
        id: existingModel.id,
        name: existingModel.name,
        description: existingModel.description,
        size: fileSize,
        filePath: file.path,
        version: version,
        downloadedAt: existingModel.downloadedAt,
        isActive: existingModel.isActive,
      );
      
      // Update model in repository
      await _repository.updateModel(updatedModel);
      
      return updatedModel;
    } catch (e) {
      throw Exception('Error updating model: $e');
    }
  }
  
  /// Gets the list of installed models
  Future<List<AIModel>> getInstalledModels() async {
    return await _repository.getAllModels();
  }
  
  /// Gets the active model
  Future<AIModel?> getActiveModel() async {
    return await _repository.getActiveModel();
  }
  
  /// Gets total available disk space in bytes
  Future<double> getAvailableDiskSpace() async {
    try {
      return await DiskSpace.getFreeDiskSpace;
    } catch (e) {
      // Fallback for platforms not supported by disk_space
      final directory = await getApplicationDocumentsDirectory();
      final stat = await directory.stat();
      return stat.size.toDouble();
    }
  }
  
  /// Gets total space used by models in bytes
  Future<int> getUsedModelSpace() async {
    try {
      final models = await _repository.getAllModels();
      return models.fold(0, (total, model) => total + model.size);
    } catch (e) {
      throw Exception('Error calculating used model space: $e');
    }
  }
  
  /// Gets models ordered by size (largest first)
  Future<List<AIModel>> getModelsOrderedBySize() async {
    try {
      final models = await _repository.getAllModels();
      models.sort((a, b) => b.size.compareTo(a.size));
      return models;
    } catch (e) {
      throw Exception('Error getting models ordered by size: $e');
    }
  }
  
  /// Closes the HTTP client when the manager is no longer needed
  void dispose() {
    _httpClient.close();
  }
}

/// Represents the progress of a model download
class DownloadProgress {
  final File file;
  final double progress;
  final int downloaded;
  final int total;
  
  DownloadProgress({
    required this.file,
    required this.progress,
    required this.downloaded,
    required this.total,
  });
  
  String get formattedProgress => '${(progress * 100).toStringAsFixed(1)}%';
  
  String get formattedDownloaded {
    if (downloaded < 1024) return '$downloaded B';
    if (downloaded < 1024 * 1024) return '${(downloaded / 1024).toStringAsFixed(1)} KB';
    if (downloaded < 1024 * 1024 * 1024) return '${(downloaded / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(downloaded / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
  
  String get formattedTotal {
    if (total < 1024) return '$total B';
    if (total < 1024 * 1024) return '${(total / 1024).toStringAsFixed(1)} KB';
    if (total < 1024 * 1024 * 1024) return '${(total / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(total / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
