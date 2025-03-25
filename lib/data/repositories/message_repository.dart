import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/message.dart';

class MessageRepository {
  static const String _boxName = 'messages';
  late Box<Message> _box;
  
  Future<void> initialize() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox<Message>(_boxName);
    } else {
      _box = Hive.box<Message>(_boxName);
    }
  }
  
  /// Pobiera wszystkie wiadomości dla danej konwersacji
  Future<List<Message>> getMessagesForConversation(String conversationId) async {
    if (!Hive.isBoxOpen(_boxName)) {
      await initialize();
    }
    
    final messages = _box.values
        .where((message) => message.conversationId == conversationId)
        .toList();
    
    messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    return messages;
  }
  
  /// Pobiera posortowane wiadomości dla danej konwersacji
  Future<List<Message>> getConversationMessagesSorted(String conversationId, {bool descending = false}) async {
    final messages = await getMessagesForConversation(conversationId);
    
    if (descending) {
      messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } else {
      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    }
    
    return messages;
  }
  
  /// Pobiera najnowsze wiadomości z różnych konwersacji
  Future<List<Message>> getLatestMessages({int limit = 10}) async {
    if (!Hive.isBoxOpen(_boxName)) {
      await initialize();
    }
    
    final messages = _box.values.toList();
    messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    // Group by conversation and take the latest from each
    final Map<String, Message> latestByConversation = {};
    for (final message in messages) {
      final conversationId = message.conversationId;
      if (!latestByConversation.containsKey(conversationId) || 
          message.timestamp.isAfter(latestByConversation[conversationId]!.timestamp)) {
        latestByConversation[conversationId] = message;
      }
    }
    
    final result = latestByConversation.values.toList();
    result.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return result.take(limit).toList();
  }
  
  /// Pobiera wiadomość po ID
  Future<Message?> getMessage(String id) async {
    if (!Hive.isBoxOpen(_boxName)) {
      await initialize();
    }
    
    try {
      return _box.get(id);
    } catch (e) {
      debugPrint('Error getting message: $e');
      return null;
    }
  }
  
  /// Tworzy nową wiadomość
  Future<Message> createMessage(Message message) async {
    if (!Hive.isBoxOpen(_boxName)) {
      await initialize();
    }
    
    try {
      await _box.put(message.id, message);
      return message;
    } catch (e) {
      debugPrint('Error creating message: $e');
      throw Exception('Failed to create message: $e');
    }
  }
  
  /// Pobiera wiele wiadomości po ID
  Future<List<Message>> getMessagesByIds(List<String> ids) async {
    if (!Hive.isBoxOpen(_boxName)) {
      await initialize();
    }
    
    final messages = <Message>[];
    
    for (final id in ids) {
      final message = await getMessage(id);
      if (message != null) {
        messages.add(message);
      }
    }
    
    messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    return messages;
  }
  
  /// Zapisuje wiadomość
  Future<void> saveMessage(Message message) async {
    if (!Hive.isBoxOpen(_boxName)) {
      await initialize();
    }
    
    try {
      await _box.put(message.id, message);
    } catch (e) {
      debugPrint('Error saving message: $e');
    }
  }
  
  /// Usuwa wiadomość
  Future<void> deleteMessage(String id) async {
    if (!Hive.isBoxOpen(_boxName)) {
      await initialize();
    }
    
    try {
      await _box.delete(id);
    } catch (e) {
      debugPrint('Error deleting message: $e');
    }
  }
  
  /// Usuwa wszystkie wiadomości dla konwersacji
  Future<void> deleteAllMessagesForConversation(String conversationId) async {
    if (!Hive.isBoxOpen(_boxName)) {
      await initialize();
    }
    
    try {
      final messageKeys = _box.values
          .where((message) => message.conversationId == conversationId)
          .map((message) => message.id)
          .toList();
      
      for (final key in messageKeys) {
        await _box.delete(key);
      }
    } catch (e) {
      debugPrint('Error deleting messages for conversation: $e');
    }
  }
  
  /// Alias dla deleteAllMessagesForConversation
  Future<void> deleteConversationMessages(String conversationId) async {
    return deleteAllMessagesForConversation(conversationId);
  }
  
  /// Zamyka box Hive
  Future<void> close() async {
    if (Hive.isBoxOpen(_boxName)) {
      await _box.close();
    }
  }
}
