import 'package:hive/hive.dart';
import 'package:lokai/models/conversation.dart';

class ConversationRepository {
  static const String _boxName = 'conversations';
  static Box? _box;
  
  /// Opens the conversations box
  Future<Box> _openBox() async {
    if (_box != null && _box!.isOpen) {
      return _box!;
    }
    
    if (Hive.isBoxOpen(_boxName)) {
      _box = Hive.box(_boxName);
      return _box!;
    }
    
    _box = await Hive.openBox(_boxName);
    return _box!;
  }
  
  /// Creates a new conversation
  Future<String> createConversation(Conversation conversation) async {
    final box = await _openBox();
    await box.put(conversation.id, conversation);
    return conversation.id;
  }
  
  /// Gets a conversation by id
  Future<Conversation?> getConversation(String id) async {
    final box = await _openBox();
    final dynamic result = box.get(id);
    if (result is Conversation) {
      return result;
    }
    return null;
  }
  
  /// Gets all conversations
  Future<List<Conversation>> getAllConversations() async {
    final box = await _openBox();
    return box.values.whereType<Conversation>().toList();
  }
  
  /// Updates a conversation
  Future<void> updateConversation(Conversation conversation) async {
    final box = await _openBox();
    conversation.updatedAt = DateTime.now();
    await box.put(conversation.id, conversation);
  }
  
  /// Deletes a conversation
  Future<void> deleteConversation(String id) async {
    final box = await _openBox();
    await box.delete(id);
  }
  
  /// Deletes all conversations
  Future<void> deleteAllConversations() async {
    final box = await _openBox();
    await box.clear();
  }
  
  /// Gets recent conversations
  Future<List<Conversation>> getRecentConversations({int limit = 10}) async {
    final box = await _openBox();
    final conversations = box.values.whereType<Conversation>().toList();
    conversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return conversations.take(limit).toList();
  }
}
