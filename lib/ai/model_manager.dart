import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../models/ai_model.dart';

class ModelDownloadException implements Exception {
  final String message;
  final String? url;
  
  ModelDownloadException(this.message, [this.url]);
  
  @override
  String toString() => 'ModelDownloadException: $message${url != null ? " (URL: $url)" : ""}';
}

class ModelVerificationException implements Exception {
  final String message;
  
  ModelVerificationException(this.message);
  
  @override
  String toString() => 'ModelVerificationException: $message';
}

class ModelManager {
  static const String _modelsFolder = 'ai_models';
  
  // Singleton pattern
  static final ModelManager _instance = ModelManager._internal();
  
  factory ModelManager() {
    return _instance;
  }
  
  ModelManager._internal();
  
  /// Gets the directory where models are stored
  Future<Directory> get _modelsDirectory async {
    final appDir = await getApplicationDocumentsDirectory();
    final modelsDir = Directory(path.join(appDir.path, _modelsFolder));
    
    if (!await modelsDir.exists()) {
      await modelsDir.create(recursive: true);
    }
    
    return modelsDir;
  }
  
  /// Downloads a model from the given URL
  /// Returns the downloaded file if successful
  Future<File> downloadModel(String url, String modelName, 
      {Function(double)? onProgress}) async {
    try {
      final client = http.Client();
      final request = http.Request('GET', Uri.parse(url));
      final response = await client.send(request);
      
      if (response.statusCode != 200) {
        throw ModelDownloadException(
            'Failed to download model: HTTP ${response.statusCode}', url);
      }
      
      final contentLength = response.contentLength ?? 0;
      int receivedBytes = 0;
      
      final modelsDir = await _modelsDirectory;
      final fileName = path.basename(url);
      final file = File(path.join(modelsDir.path, fileName));
      
      final sink = file.openWrite();
      
      await response.stream.forEach((chunk) {
        sink.add(chunk);
        receivedBytes += chunk.length;
        
        if (contentLength > 0 && onProgress != null) {
          onProgress(receivedBytes / contentLength);
        }
      });
      
      await sink.flush();
      await sink.close();
      
      return file;
    } catch (e) {
      if (e is ModelDownloadException) {
        rethrow;
      }
      throw ModelDownloadException('Error downloading model: ${e.toString()}', url);
    }
  }
  
  /// Verifies the integrity of a downloaded model file using a hash
  Future<bool> verifyModelIntegrity(File modelFile, String expectedHash, 
      {String algorithm = 'sha256'}) async {
    try {
      final bytes = await modelFile.readAsBytes();
      String actualHash;
      
      switch (algorithm.toLowerCase()) {
        case 'md5':
          actualHash = md5.convert(bytes).toString();
          break;
        case 'sha1':
          actualHash = sha1.convert(bytes).toString();
          break;
        case 'sha256':
        default:
          actualHash = sha256.convert(bytes).toString();
          break;
      }
      
      return expectedHash.toLowerCase() == actualHash.toLowerCase();
    } catch (e) {
      throw ModelVerificationException('Error verifying model: ${e.toString()}');
    }
  }
  
  /// Installs a model after it has been downloaded and verified
  Future<AIModel> installModel(File modelFile, String modelName, String description, 
      {int size = 0, String version = '1.0.0'}) async {
    try {
      final modelsDir = await _modelsDirectory;
      final destPath = path.join(modelsDir.path, 
          '${modelName.replaceAll(' ', '_').toLowerCase()}_$version.bin');
      
      // If destination path is different from current path, copy the file
      if (destPath != modelFile.path) {
        final destFile = await modelFile.copy(destPath);
        
        // If we're moving the file from a temporary location, delete the original
        if (path.dirname(modelFile.path) != modelsDir.path) {
          await modelFile.delete();
        }
        
        modelFile = destFile;
      }
      
      // Create model metadata
      final model = AIModel(
        name: modelName,
        description: description,
        size: size > 0 ? size : await modelFile.length(),
        filePath: modelFile.path,
        version: version,
        downloadedAt: DateTime.now(),
      );
      
      // Return the model (it should be saved to repository by the caller)
      return model;
    } catch (e) {
      throw Exception('Error installing model: ${e.toString()}');
    }
  }
  
  /// Uninstalls a model by deleting its file
  Future<bool> uninstallModel(AIModel model) async {
    try {
      final file = File(model.filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error uninstalling model: ${e.toString()}');
      return false;
    }
  }
  
  /// Gets the total size of all installed models
  Future<int> getUsedDiskSpace() async {
    try {
      final modelsDir = await _modelsDirectory;
      final entities = await modelsDir.list().toList();
      
      int totalSize = 0;
      for (var entity in entities) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      
      return totalSize;
    } catch (e) {
      debugPrint('Error calculating used disk space: ${e.toString()}');
      return 0;
    }
  }
  
  /// Gets available disk space (approximate)
  Future<int> getAvailableDiskSpace() async {
    try {
      // This is platform-specific and may not work on all devices
      // For a more robust solution, consider using a plugin like disk_space
      
      // Get the application directory as a proxy for device storage
      final appDir = await getApplicationDocumentsDirectory();
      final stat = Directory(appDir.path).statSync();
      
      // This is an approximation and may not be available on all platforms
      return stat.size;
    } catch (e) {
      debugPrint('Error getting available disk space: ${e.toString()}');
      return 0;
    }
  }
  
  /// Gets a list of all model files in the models directory
  Future<List<File>> getModelFiles() async {
    try {
      final modelsDir = await _modelsDirectory;
      final entities = await modelsDir.list().toList();
      
      final modelFiles = <File>[];
      for (var entity in entities) {
        if (entity is File) {
          modelFiles.add(entity);
        }
      }
      
      return modelFiles;
    } catch (e) {
      debugPrint('Error getting model files: ${e.toString()}');
      return [];
    }
  }
  
  /// Checks if a model with the given name and version exists
  Future<bool> modelExists(String modelName, String version) async {
    try {
      final modelsDir = await _modelsDirectory;
      final expectedPath = path.join(modelsDir.path, 
          '${modelName.replaceAll(' ', '_').toLowerCase()}_$version.bin');
      
      return await File(expectedPath).exists();
    } catch (e) {
      debugPrint('Error checking if model exists: ${e.toString()}');
      return false;
    }
  }
  
  /// Gets the path for a model file based on its name and version
  Future<String> getModelPath(String modelName, String version) async {
    final modelsDir = await _modelsDirectory;
    return path.join(modelsDir.path, 
        '${modelName.replaceAll(' ', '_').toLowerCase()}_$version.bin');
  }
  
  /// Gets a list of all installed models
  Future<List<AIModel>> getInstalledModels() async {
    try {
      final modelFiles = await getModelFiles();
      final models = <AIModel>[];
      
      for (var file in modelFiles) {
        final fileName = path.basename(file.path);
        // Parse the filename to extract name and version
        // Assuming filename format: modelname_version.bin
        final parts = fileName.split('_');
        if (parts.length < 2) continue;
        
        final version = parts.last.replaceAll('.bin', '');
        final name = parts.take(parts.length - 1).join('_');
        
        models.add(AIModel(
          name: name,
          description: 'Installed model',
          size: await file.length(),
          filePath: file.path,
          version: version,
          downloadedAt: await file.lastModified(),
        ));
      }
      
      return models;
    } catch (e) {
      debugPrint('Error getting installed models: ${e.toString()}');
      return [];
    }
  }
  
  /// Calculates the hash of a file
  Future<String> calculateFileHash(File file, {String algorithm = 'sha256'}) async {
    try {
      final bytes = await file.readAsBytes();
      String hash;
      
      switch (algorithm.toLowerCase()) {
        case 'md5':
          hash = md5.convert(bytes).toString();
          break;
        case 'sha1':
          hash = sha1.convert(bytes).toString();
          break;
        case 'sha256':
        default:
          hash = sha256.convert(bytes).toString();
          break;
      }
      
      return hash;
    } catch (e) {
      throw Exception('Error calculating file hash: ${e.toString()}');
    }
  }
}
