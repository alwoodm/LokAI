import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../models/ai_model.dart';

/// Exception thrown when there are issues with TFLite operations
class TFLiteException implements Exception {
  final String message;
  final Object? originalException;

  TFLiteException(this.message, [this.originalException]);

  @override
  String toString() => 'TFLiteException: $message${originalException != null ? ' ($originalException)' : ''}';
}

/// Service for managing TensorFlow Lite interpreters and model inference
class TFLiteService {
  // Singleton pattern
  static final TFLiteService _instance = TFLiteService._internal();
  factory TFLiteService() => _instance;
  TFLiteService._internal();

  // Cache of active interpreters
  final Map<String, Interpreter> _interpreters = {};
  
  /// Initializes the TFLite service
  Future<void> initialize() async {
    try {
      // Check TFLite availability by attempting to create an interpreter with an empty model
      // This will throw an exception if TFLite is not available
      debugPrint('Initializing TensorFlow Lite...');
      
      // Since there's no direct method to get the version, we'll just verify it's working
      // by checking if we can create a delegate (which requires TFLite to be properly initialized)
      final gpuAvailable = await isGpuAvailable();
      debugPrint('TensorFlow Lite initialized successfully. GPU acceleration available: $gpuAvailable');
    } catch (e) {
      debugPrint('Failed to initialize TFLite: $e');
      throw TFLiteException('Failed to initialize TensorFlow Lite', e);
    }
  }
  
  /// Loads a model from the given file path
  /// 
  /// [modelPath] is the path to the model file
  /// [useGpu] enables GPU acceleration if available
  /// [numThreads] sets the number of threads for CPU execution
  Future<Interpreter> loadModel(String modelPath, {bool useGpu = false, int numThreads = 2}) async {
    if (_interpreters.containsKey(modelPath)) {
      return _interpreters[modelPath]!;
    }
    
    try {
      final interpreterOptions = InterpreterOptions()..threads = numThreads;
      
      // Enable GPU acceleration if requested
      if (useGpu) {
        try {
          interpreterOptions.addDelegate(GpuDelegateV2());
          debugPrint('GPU acceleration enabled');
        } catch (e) {
          debugPrint('GPU acceleration not available: $e');
        }
      }
      
      // Load model from file
      final interpreter = Interpreter.fromFile(
        File(modelPath),
        options: interpreterOptions,
      );
      
      _interpreters[modelPath] = interpreter;
      debugPrint('Model loaded: $modelPath');
      
      return interpreter;
    } catch (e) {
      debugPrint('Failed to load model: $e');
      throw TFLiteException('Failed to load model from $modelPath', e);
    }
  }
  
  /// Loads a model using the AIModel information
  Future<Interpreter> loadAIModel(AIModel model, {bool useGpu = false, int numThreads = 2}) async {
    return loadModel(model.filePath, useGpu: useGpu, numThreads: numThreads);
  }
  
  /// Runs inference on the model with the given input data
  /// 
  /// [interpreter] is the loaded TFLite interpreter
  /// [inputs] is a list of input tensors
  /// [outputs] is a map of output tensor indices to output buffers
  Future<Map<int, Object>> runInference(
    Interpreter interpreter,
    List<Object> inputs,
    Map<int, Object> outputs,
  ) async {
    try {
      interpreter.runForMultipleInputs(inputs, outputs);
      return outputs;
    } catch (e) {
      debugPrint('Inference error: $e');
      throw TFLiteException('Error during model inference', e);
    }
  }
  
  /// Gets input tensor details
  List<Tensor> getInputTensors(Interpreter interpreter) {
    return interpreter.getInputTensors();
  }
  
  /// Gets output tensor details
  List<Tensor> getOutputTensors(Interpreter interpreter) {
    return interpreter.getOutputTensors();
  }
  
  /// Allocates tensors for the model
  void allocateTensors(Interpreter interpreter) {
    try {
      interpreter.allocateTensors();
    } catch (e) {
      debugPrint('Failed to allocate tensors: $e');
      throw TFLiteException('Failed to allocate tensors', e);
    }
  }
  
  /// Releases the resources associated with the interpreter
  void closeModel(String modelPath) {
    if (_interpreters.containsKey(modelPath)) {
      try {
        _interpreters[modelPath]!.close();
        _interpreters.remove(modelPath);
        debugPrint('Model closed: $modelPath');
      } catch (e) {
        debugPrint('Error closing model: $e');
      }
    }
  }
  
  /// Releases all interpreter resources
  void closeAll() {
    for (final modelPath in _interpreters.keys.toList()) {
      closeModel(modelPath);
    }
    debugPrint('All models closed');
  }
  
  /// Checks if GPU acceleration is available
  Future<bool> isGpuAvailable() async {
    try {
      // Try to create a GPU delegate to check availability
      final gpuDelegate = GpuDelegateV2();
      gpuDelegate.delete();
      return true;
    } catch (e) {
      debugPrint('GPU acceleration check failed: $e');
      return false;
    }
  }
  
  /// Creates a benchmark for the given model
  Future<ModelBenchmark> benchmarkModel(String modelPath, {bool useGpu = false}) async {
    final benchmark = ModelBenchmark(modelPath, this);
    await benchmark.run(useGpu: useGpu);
    return benchmark;
  }
}

/// Class for benchmarking model performance
class ModelBenchmark {
  final String modelPath;
  final TFLiteService service;
  
  late final int _iterations;
  double _avgInferenceTime = 0.0;
  double _minInferenceTime = double.infinity;
  double _maxInferenceTime = 0.0;
  
  ModelBenchmark(this.modelPath, this.service, {int iterations = 10}) : _iterations = iterations;
  
  /// Runs the benchmark
  Future<void> run({bool useGpu = false}) async {
    try {
      final interpreter = await service.loadModel(modelPath, useGpu: useGpu);
      
      // Get input and output shapes
      final inputTensors = service.getInputTensors(interpreter);
      final outputTensors = service.getOutputTensors(interpreter);
      
      if (inputTensors.isEmpty || outputTensors.isEmpty) {
        throw TFLiteException('Invalid model: no input or output tensors found');
      }
      
      // Create dummy input data
      final inputs = <Object>[];
      for (final tensor in inputTensors) {
        inputs.add(_createDummyInput(tensor.shape, tensor.type));
      }
      
      // Create output buffers
      final outputs = <int, Object>{};
      for (var i = 0; i < outputTensors.length; i++) {
        final tensor = outputTensors[i];
        outputs[i] = _createOutputBuffer(tensor.shape, tensor.type);
      }
      
      // Run the benchmark
      double totalTime = 0;
      
      for (var i = 0; i < _iterations; i++) {
        final stopwatch = Stopwatch()..start();
        
        await service.runInference(interpreter, inputs, outputs);
        
        stopwatch.stop();
        final inferenceTime = stopwatch.elapsedMilliseconds.toDouble();
        totalTime += inferenceTime;
        
        _minInferenceTime = inferenceTime < _minInferenceTime ? inferenceTime : _minInferenceTime;
        _maxInferenceTime = inferenceTime > _maxInferenceTime ? inferenceTime : _maxInferenceTime;
        
        debugPrint('Benchmark iteration $i: ${inferenceTime}ms');
      }
      
      _avgInferenceTime = totalTime / _iterations;
      debugPrint('Benchmark complete: avg=${_avgInferenceTime}ms, min=${_minInferenceTime}ms, max=${_maxInferenceTime}ms');
      
      // Clean up after benchmark
      service.closeModel(modelPath);
    } catch (e) {
      debugPrint('Benchmark failed: $e');
      throw TFLiteException('Benchmark failed', e);
    }
  }
  
  /// Gets the benchmark results
  Map<String, dynamic> getResults() {
    return {
      'modelPath': modelPath,
      'iterations': _iterations,
      'avgInferenceTime': _avgInferenceTime,
      'minInferenceTime': _minInferenceTime,
      'maxInferenceTime': _maxInferenceTime,
    };
  }
  
  /// Creates dummy input data for the benchmark
  dynamic _createDummyInput(List<int> shape, TensorType type) {
    switch (type) {
      case TensorType.float32:
        return _createFloatTensor(shape);
      case TensorType.int32:
        return _createIntTensor(shape);
      case TensorType.uint8:
        return _createUint8Tensor(shape);
      default:
        throw TFLiteException('Unsupported input tensor type: $type');
    }
  }
  
  /// Creates output buffer for the benchmark
  dynamic _createOutputBuffer(List<int> shape, TensorType type) {
    switch (type) {
      case TensorType.float32:
        return _createFloatTensor(shape);
      case TensorType.int32:
        return _createIntTensor(shape);
      case TensorType.uint8:
        return _createUint8Tensor(shape);
      default:
        throw TFLiteException('Unsupported output tensor type: $type');
    }
  }
  
  /// Creates a float tensor with the given shape
  List<double> _createFloatTensor(List<int> shape) {
    int size = shape.fold(1, (a, b) => a * b);
    return List<double>.filled(size, 0.0);
  }
  
  /// Creates an int tensor with the given shape
  List<int> _createIntTensor(List<int> shape) {
    int size = shape.fold(1, (a, b) => a * b);
    return List<int>.filled(size, 0);
  }
  
  /// Creates a uint8 tensor with the given shape
  List<int> _createUint8Tensor(List<int> shape) {
    int size = shape.fold(1, (a, b) => a * b);
    return List<int>.filled(size, 0);
  }
}
