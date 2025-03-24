import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class Conversation {
  final String id;
  String title;
  final DateTime createdAt;
  DateTime updatedAt;

  /// Creates a new conversation with the given parameters.
  Conversation({
    String? id,
    required this.title,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : 
    id = id ?? const Uuid().v4(),
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();
  
  /// Creates a conversation from a JSON map.
  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
  
  /// Converts the conversation to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
  
  /// Returns a copy of this conversation with the specified fields replaced.
  Conversation copyWith({
    String? title,
    DateTime? updatedAt,
  }) {
    return Conversation(
      id: id,
      title: title ?? this.title,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  @override
  String toString() {
    return 'Conversation(id: $id, title: $title, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Conversation && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}

class ConversationAdapter extends TypeAdapter<Conversation> {
  @override
  final int typeId = 1;

  @override
  Conversation read(BinaryReader reader) {
    final id = reader.readString();
    final title = reader.readString();
    final createdAt = DateTime.parse(reader.readString());
    final updatedAt = DateTime.parse(reader.readString());
    
    return Conversation(
      id: id,
      title: title,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  void write(BinaryWriter writer, Conversation obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeString(obj.createdAt.toIso8601String());
    writer.writeString(obj.updatedAt.toIso8601String());
  }
}
