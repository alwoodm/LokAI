import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokai/ai/tflite_service.dart';
import 'package:lokai/models/ai_model.dart';

/// Helper class for testing model inference
class ModelInferenceHelper {
  final WidgetRef ref;
  final TFLiteService _tfliteService = TFLiteService();
  
  ModelInferenceHelper(this.ref);
  
  /// Tests loading and inference on a model
  Future<bool> testModelInference(BuildContext context, AIModel model) async {
    if (!File(model.filePath).existsSync()) {
      _showMessage(context, 'Model file not found: ${model.filePath}');
      return false;
    }
    
    // Show loading dialog
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => _buildLoadingDialog('Testing model ${model.name}...'),
      );
    }
    
    try {
      // Load the model
      final interpreter = await _tfliteService.loadModel(
        model.filePath,
        useGpu: true,
      );
      
      // Show model information
      final inputTensors = _tfliteService.getInputTensors(interpreter);
      final outputTensors = _tfliteService.getOutputTensors(interpreter);
      
      final modelInfo = StringBuffer();
      modelInfo.writeln('Model loaded successfully!');
      modelInfo.writeln('Input tensors: ${inputTensors.length}');
      
      for (var i = 0; i < inputTensors.length; i++) {
        final tensor = inputTensors[i];
        modelInfo.writeln('  Input $i: shape=${tensor.shape}, type=${tensor.type}');
      }
      
      modelInfo.writeln('Output tensors: ${outputTensors.length}');
      for (var i = 0; i < outputTensors.length; i++) {
        final tensor = outputTensors[i];
        modelInfo.writeln('  Output $i: shape=${tensor.shape}, type=${tensor.type}');
      }
      
      // Run the benchmark
      final benchmark = await _tfliteService.benchmarkModel(model.filePath, useGpu: true);
      final results = benchmark.getResults();
      
      modelInfo.writeln('\nBenchmark results:');
      modelInfo.writeln('  Iterations: ${results['iterations']}');
      modelInfo.writeln('  Avg inference time: ${results['avgInferenceTime'].toStringAsFixed(2)}ms');
      modelInfo.writeln('  Min inference time: ${results['minInferenceTime'].toStringAsFixed(2)}ms');
      modelInfo.writeln('  Max inference time: ${results['maxInferenceTime'].toStringAsFixed(2)}ms');
      
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      
      // Show model information dialog
      if (context.mounted) {
        _showModelInfoDialog(context, modelInfo.toString());
      }
      
      return true;
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      
      // Show error message
      if (context.mounted) {
        _showMessage(context, 'Error testing model: $e');
      }
      
      return false;
    }
  }
  
  /// Checks if GPU acceleration is available
  Future<bool> isGpuAvailable(BuildContext context) async {
    try {
      final isAvailable = await _tfliteService.isGpuAvailable();
      if (context.mounted) {
        _showMessage(
          context, 
          isAvailable 
              ? 'GPU acceleration is available!' 
              : 'GPU acceleration is not available'
        );
      }
      return isAvailable;
    } catch (e) {
      if (context.mounted) {
        _showMessage(context, 'Error checking GPU availability: $e');
      }
      return false;
    }
  }
  
  /// Builds a loading dialog widget
  Widget _buildLoadingDialog(String message) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(message),
        ],
      ),
    );
  }
  
  /// Shows a message to the user
  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
  
  /// Shows model information dialog
  void _showModelInfoDialog(BuildContext context, String info) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Model Information'),
        content: SingleChildScrollView(
          child: Text(info),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
