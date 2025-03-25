import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class Conversation {
  final String id;
  String title;
  final DateTime createdAt;
  DateTime updatedAt;
  final List<String> messageIds; // Przechowuje ID wiadomości
  final String modelId; // ID modelu używanego do tej konwersacji
  int tokenCount; // Liczba tokenów używana do śledzenia kontekstu

  Conversation({
    String? id,
    required this.title,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? messageIds,
    required this.modelId,
    this.tokenCount = 0,
  }) : 
    id = id ?? const Uuid().v4(),
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now(),
    messageIds = messageIds ?? [];

  /// Tworzy obiekt Conversation z mapy JSON
  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      messageIds: List<String>.from(json['messageIds'] as List),
      modelId: json['modelId'] as String,
      tokenCount: json['tokenCount'] as int? ?? 0,
    );
  }

  /// Konwertuje obiekt Conversation do mapy JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'messageIds': messageIds,
      'modelId': modelId,
      'tokenCount': tokenCount,
    };
  }

  /// Aktualizuje czas ostatniej modyfikacji
  void touch() {
    updatedAt = DateTime.now();
  }

  /// Dodaje ID wiadomości do konwersacji
  void addMessageId(String messageId) {
    messageIds.add(messageId);
    touch();
  }

  /// Generuje tytuł na podstawie pierwszej wiadomości użytkownika
  void generateTitle(String firstUserMessage) {
    // Uproszczona logika generowania tytułu
    if (firstUserMessage.length > 50) {
      title = '${firstUserMessage.substring(0, 47)}...';
    } else {
      title = firstUserMessage;
    }
    touch();
  }

  @override
  String toString() => 'Conversation(id: $id, title: $title)';
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
    final messageIds = List<String>.from(reader.readList());
    final modelId = reader.readString();
    final tokenCount = reader.readInt();

    return Conversation(
      id: id,
      title: title,
      createdAt: createdAt,
      updatedAt: updatedAt,
      messageIds: messageIds,
      modelId: modelId,
      tokenCount: tokenCount,
    );
  }

  @override
  void write(BinaryWriter writer, Conversation obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeString(obj.createdAt.toIso8601String());
    writer.writeString(obj.updatedAt.toIso8601String());
    writer.writeList(obj.messageIds);
    writer.writeString(obj.modelId);
    writer.writeInt(obj.tokenCount);
  }
}
