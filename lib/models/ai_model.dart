import 'package:uuid/uuid.dart';

/// Represents an AI model that can be used by the application.
class AIModel {
  /// Unique identifier for the model
  final String id;
  
  /// Name of the model
  final String name;
  
  /// Description of the model and its capabilities
  final String description;
  
  /// Size of the model file in bytes
  final int size;
  
  /// Path to the model file on the device
  final String filePath;
  
  /// When the model was downloaded
  final DateTime downloadedAt;
  
  /// Version of the model
  final String version;
  
  /// Whether the model is currently in use
  bool isActive;

  /// Creates a new AIModel with the given parameters.
  AIModel({
    String? id,
    required this.name,
    required this.description,
    required this.size,
    required this.filePath,
    DateTime? downloadedAt,
    required this.version,
    this.isActive = false,
  }) : 
    id = id ?? const Uuid().v4(),
    downloadedAt = downloadedAt ?? DateTime.now();
  
  /// Creates an AIModel from a JSON map.
  factory AIModel.fromJson(Map<String, dynamic> json) {
    return AIModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      size: json['size'] as int,
      filePath: json['filePath'] as String,
      downloadedAt: DateTime.parse(json['downloadedAt'] as String),
      version: json['version'] as String,
      isActive: json['isActive'] as bool? ?? false,
    );
  }
  
  /// Converts the AIModel to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'size': size,
      'filePath': filePath,
      'downloadedAt': downloadedAt.toIso8601String(),
      'version': version,
      'isActive': isActive,
    };
  }
  
  /// Returns the size of the model in a human-readable format.
  String get formattedSize {
    const int kb = 1024;
    const int mb = kb * 1024;
    const int gb = mb * 1024;
    
    if (size >= gb) {
      return '${(size / gb).toStringAsFixed(2)} GB';
    }
    if (size >= mb) {
      return '${(size / mb).toStringAsFixed(2)} MB';
    }
    if (size >= kb) {
      return '${(size / kb).toStringAsFixed(2)} KB';
    }
    return '$size bytes';
  }
  
  @override
  String toString() {
    return 'AIModel(id: $id, name: $name, version: $version, size: $formattedSize)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AIModel && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}
