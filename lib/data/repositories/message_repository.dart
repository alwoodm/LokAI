import 'package:hive/hive.dart';
import 'package:lokai/models/message.dart';

class MessageRepository {
  static const String _boxName = 'messages';
  static Box? _box;
  
  /// Opens the messages box
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
  
  /// Creates a new message
  Future<String> createMessage(Message message) async {
    final box = await _openBox();
    await box.put(message.id, message);
    return message.id;
  }
  
  /// Gets a message by id
  Future<Message?> getMessage(String id) async {
    final box = await _openBox();
    final dynamic result = box.get(id);
    if (result is Message) {
      return result;
    }
    return null;
  }
  
  /// Gets all messages for a conversation
  Future<List<Message>> getConversationMessages(String conversationId) async {
    final box = await _openBox();
    return box.values
        .whereType<Message>()
        .where((message) => message.conversationId == conversationId)
        .toList();
  }
  
  /// Gets messages for a conversation sorted by timestamp
  Future<List<Message>> getConversationMessagesSorted(String conversationId) async {
    final messages = await getConversationMessages(conversationId);
    messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return messages;
  }
  
  /// Deletes a message
  Future<void> deleteMessage(String id) async {
    final box = await _openBox();
    await box.delete(id);
  }
  
  /// Deletes all messages for a conversation
  Future<void> deleteConversationMessages(String conversationId) async {
    final box = await _openBox();
    final messagesToDelete = box.values.where((message) => 
      message.conversationId == conversationId
    ).map((message) => message.id).toList();
    
    for (final id in messagesToDelete) {
      await box.delete(id);
    }
  }
  
  /// Gets the latest message for each conversation
  Future<Map<String, Message>> getLatestMessages() async {
    final box = await _openBox();
    final messages = box.values.whereType<Message>().toList();
    
    // Group messages by conversation ID
    final Map<String, List<Message>> groupedMessages = {};
    for (final message in messages) {
      if (!groupedMessages.containsKey(message.conversationId)) {
        groupedMessages[message.conversationId] = [];
      }
      groupedMessages[message.conversationId]!.add(message);
    }
    
    // Get the latest message for each conversation
    final Map<String, Message> latestMessages = {};
    for (final entry in groupedMessages.entries) {
      final conversationMessages = entry.value;
      conversationMessages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      latestMessages[entry.key] = conversationMessages.first;
    }
    
    return latestMessages;
  }
}
