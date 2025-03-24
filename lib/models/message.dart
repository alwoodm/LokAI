import 'package:uuid/uuid.dart';

/// Represents a single message in a conversation.
class Message {
  /// Unique identifier for the message
  final String id;
  
  /// Content of the message
  final String text;
  
  /// Whether the message was sent by the user (true) or the AI (false)
  final bool isUser;
  
  /// ID of the conversation this message belongs to
  final String conversationId;
  
  /// When the message was sent or received
  final DateTime timestamp;

  /// Creates a new message with the given parameters.
  Message({
    String? id,
    required this.text,
    required this.isUser,
    required this.conversationId,
    DateTime? timestamp,
  }) : 
    id = id ?? const Uuid().v4(),
    timestamp = timestamp ?? DateTime.now();
  
  /// Creates a message from a JSON map.
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      text: json['text'] as String,
      isUser: json['isUser'] as bool,
      conversationId: json['conversationId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
  
  /// Converts the message to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isUser': isUser,
      'conversationId': conversationId,
      'timestamp': timestamp.toIso8601String(),
    };
  }
  
  @override
  String toString() {
    return 'Message(id: $id, isUser: $isUser, text: ${text.length > 20 ? "${text.substring(0, 20)}..." : text}, conversationId: $conversationId, timestamp: $timestamp)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Message && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}
