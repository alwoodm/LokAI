import 'package:uuid/uuid.dart';

/// Represents a conversation between the user and the AI.
class Conversation {
  /// Unique identifier for the conversation
  final String id;
  
  /// Title of the conversation
  String title;
  
  /// When the conversation was created
  final DateTime createdAt;
  
  /// When the conversation was last updated
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
