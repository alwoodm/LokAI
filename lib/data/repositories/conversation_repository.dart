import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lokai/models/conversation.dart';

class ConversationRepository {
  static const String _boxName = 'conversations';
  late Box<Conversation> _box;
  
  Future<void> initialize() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox<Conversation>(_boxName);
    } else {
      _box = Hive.box<Conversation>(_boxName);
    }
  }
  
  /// Pobiera wszystkie konwersacje posortowane według czasu aktualizacji (od najnowszej)
  Future<List<Conversation>> getAllConversations() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await initialize();
    }
    
    final conversations = _box.values.toList();
    conversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    
    return conversations;
  }
  
  /// Pobiera ostatnie n konwersacji
  Future<List<Conversation>> getRecentConversations({int limit = 10}) async {
    final allConversations = await getAllConversations();
    return allConversations.take(limit).toList();
  }
  
  /// Pobiera konwersację po ID
  Future<Conversation?> getConversation(String id) async {
    if (!Hive.isBoxOpen(_boxName)) {
      await initialize();
    }
    
    try {
      return _box.get(id);
    } catch (e) {
      debugPrint('Error getting conversation: $e');
      return null;
    }
  }
  
  /// Tworzy nową konwersację
  Future<Conversation> createConversation(Conversation conversation) async {
    if (!Hive.isBoxOpen(_boxName)) {
      await initialize();
    }
    
    try {
      await _box.put(conversation.id, conversation);
      return conversation;
    } catch (e) {
      debugPrint('Error creating conversation: $e');
      throw Exception('Failed to create conversation: $e');
    }
  }
  
  /// Zapisuje konwersację
  Future<void> saveConversation(Conversation conversation) async {
    if (!Hive.isBoxOpen(_boxName)) {
      await initialize();
    }
    
    try {
      await _box.put(conversation.id, conversation);
    } catch (e) {
      debugPrint('Error saving conversation: $e');
    }
  }
  
  /// Aktualizuje konwersację
  Future<void> updateConversation(Conversation conversation) async {
    if (!Hive.isBoxOpen(_boxName)) {
      await initialize();
    }
    
    try {
      await _box.put(conversation.id, conversation);
    } catch (e) {
      debugPrint('Error updating conversation: $e');
    }
  }
  
  /// Usuwa konwersację
  Future<void> deleteConversation(String id) async {
    if (!Hive.isBoxOpen(_boxName)) {
      await initialize();
    }
    
    try {
      await _box.delete(id);
    } catch (e) {
      debugPrint('Error deleting conversation: $e');
    }
  }
  
  /// Usuwa wszystkie konwersacje
  Future<void> deleteAllConversations() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await initialize();
    }
    
    try {
      await _box.clear();
    } catch (e) {
      debugPrint('Error deleting all conversations: $e');
    }
  }
  
  /// Sprawdza, czy konwersacja istnieje
  Future<bool> exists(String id) async {
    if (!Hive.isBoxOpen(_boxName)) {
      await initialize();
    }
    
    return _box.containsKey(id);
  }
  
  /// Zamyka box Hive
  Future<void> close() async {
    if (Hive.isBoxOpen(_boxName)) {
      await _box.close();
    }
  }
}
