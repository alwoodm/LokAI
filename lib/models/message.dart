import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

// Usuwamy part directive, ponieważ implementujemy adapter ręcznie
// part 'message.g.dart';

class Message {
  final String id;
  final String text;
  final bool isUser;
  final String conversationId;
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

class MessageAdapter extends TypeAdapter<Message> {
  @override
  final int typeId = 2;

  @override
  Message read(BinaryReader reader) {
    final id = reader.readString();
    final text = reader.readString();
    final isUser = reader.readBool();
    final conversationId = reader.readString();
    final timestamp = DateTime.parse(reader.readString());
    
    return Message(
      id: id,
      text: text,
      isUser: isUser,
      conversationId: conversationId,
      timestamp: timestamp,
    );
  }

  @override
  void write(BinaryWriter writer, Message obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.text);
    writer.writeBool(obj.isUser);
    writer.writeString(obj.conversationId);
    writer.writeString(obj.timestamp.toIso8601String());
  }
}
