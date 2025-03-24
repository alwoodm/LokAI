import 'package:hive/hive.dart';
import 'package:lokai/models/conversation.dart';

class ConversationRepository {
  static const String _boxName = 'conversations';
  
  /// Opens the conversations box
  Future<Box<Conversation>> _openBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox<Conversation>(_boxName);
    }
    return Hive.box<Conversation>(_boxName);
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
    return box.get(id);
  }
  
  /// Gets all conversations
  Future<List<Conversation>> getAllConversations() async {
    final box = await _openBox();
    return box.values.toList();
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
    final conversations = box.values.toList();
    conversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return conversations.take(limit).toList();
  }
}
