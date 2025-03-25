import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

// Usuwamy part directive, ponieważ implementujemy adapter ręcznie
// part 'ai_model.g.dart';

class AIModel {
  final String id;
  final String name;
  final String description;
  final int size;
  final String filePath;
  final DateTime? downloadedAt;
  final String version;
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
      'downloadedAt': downloadedAt?.toIso8601String(),
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

  // Create a copy of this model with updated fields
  AIModel copyWith({
    String? name,
    String? description,
    int? size,
    String? filePath,
    String? version,
    DateTime? downloadedAt,
  }) {
    return AIModel(
      id: id, // Removed 'this.'
      name: name ?? this.name,
      description: description ?? this.description,
      size: size ?? this.size,
      filePath: filePath ?? this.filePath,
      version: version ?? this.version,
      downloadedAt: downloadedAt ?? this.downloadedAt,
    );
  }
}

class AIModelAdapter extends TypeAdapter<AIModel> {
  @override
  final int typeId = 3;

  @override
  AIModel read(BinaryReader reader) {
    final id = reader.readString();
    final name = reader.readString();
    final description = reader.readString();
    final size = reader.readInt();
    final filePath = reader.readString();
    final downloadedAt = DateTime.parse(reader.readString());
    final version = reader.readString();
    final isActive = reader.readBool();
    
    return AIModel(
      id: id,
      name: name,
      description: description,
      size: size,
      filePath: filePath,
      downloadedAt: downloadedAt,
      version: version,
      isActive: isActive,
    );
  }

  @override
  void write(BinaryWriter writer, AIModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeString(obj.description);
    writer.writeInt(obj.size);
    writer.writeString(obj.filePath);
    writer.writeString(obj.downloadedAt?.toIso8601String() ?? '');
    writer.writeString(obj.version);
    writer.writeBool(obj.isActive);
  }
}
