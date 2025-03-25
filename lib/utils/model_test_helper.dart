import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokai/services/model_service.dart';
import 'package:lokai/models/ai_model.dart';

/// Helper class for testing model downloads
class ModelTestHelper {
  final WidgetRef ref;
  
  ModelTestHelper(this.ref);
  
  /// Downloads a test model and returns the result
  Future<AIModel?> downloadTestModel({
    required BuildContext context,
    String url = 'https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-tiny.en.bin',
    String modelName = 'WhisperTest',
    String description = 'Test model for verification',
    String expectedHash = '', // You should provide a valid hash for production use
    Function(double)? onProgress,
  }) async {
    final modelService = ref.read(modelServiceProvider);
    
    // Show a progress dialog
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Downloading $modelName'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const LinearProgressIndicator(),
                const SizedBox(height: 16),
                Text('Please wait while the model is being downloaded...'),
              ],
            ),
          );
        },
      );
    }
    
    // Download the model
    final model = await modelService.downloadAndInstallModel(
      url,
      modelName,
      description,
      expectedHash,
      onProgress: (progress) {
        // Update progress if needed
        debugPrint('Download progress: ${(progress * 100).toStringAsFixed(2)}%');
        onProgress?.call(progress);
      },
    );
    
    // Close the dialog
    if (context.mounted) {
      Navigator.of(context).pop();
    }
    
    // Show result
    if (model != null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Model $modelName downloaded successfully')),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to download model $modelName')),
        );
      }
    }
    
    return model;
  }
  
  /// Displays storage information
  Future<void> showStorageInfo(BuildContext context) async {
    final modelService = ref.read(modelServiceProvider);
    
    final usedSpace = await modelService.getUsedDiskSpaceFormatted();
    final availableSpace = await modelService.getAvailableDiskSpaceFormatted();
    
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Storage Information'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Used space: $usedSpace'),
                Text('Available space: $availableSpace'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}
