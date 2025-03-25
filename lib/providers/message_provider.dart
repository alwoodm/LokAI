import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokai/data/repositories/message_repository.dart';
import 'package:lokai/models/message.dart';

// Provider dla repozytorium wiadomości
final messageRepositoryProvider = Provider<MessageRepository>((ref) {
  return MessageRepository();
});

// Provider dla posortowanych wiadomości w konwersacji
final conversationMessagesProvider = FutureProvider.family<List<Message>, String>((ref, conversationId) async {
  final repository = ref.watch(messageRepositoryProvider);
  return repository.getConversationMessagesSorted(conversationId);
});

// Provider dla najnowszych wiadomości
final latestMessagesProvider = FutureProvider<List<Message>>((ref) async {
  final repository = ref.watch(messageRepositoryProvider);
  return repository.getLatestMessages();
});

// Provider dla pojedynczej wiadomości
final messageProvider = FutureProvider.family<Message?, String>((ref, id) async {
  final repository = ref.watch(messageRepositoryProvider);
  return repository.getMessage(id);
});

// Notifier dla operacji na wiadomościach
class MessageNotifier extends StateNotifier<List<Message>> {
  final MessageRepository _repository;
  
  MessageNotifier(this._repository) : super([]);
  
  Future<void> loadMessagesForConversation(String conversationId) async {
    final messages = await _repository.getConversationMessagesSorted(conversationId);
    state = messages;
  }
  
  Future<Message> createNewMessage(String text, bool isUser, String conversationId) async {
    final message = Message(
      text: text,
      isUser: isUser,
      conversationId: conversationId,
    );
    
    final createdMessage = await _repository.createMessage(message);
    state = [...state, createdMessage];
    return createdMessage;
  }
  
  Future<void> saveMessage(Message message) async {
    await _repository.saveMessage(message);
    
    // Update state if message already exists, otherwise add it
    final index = state.indexWhere((m) => m.id == message.id);
    if (index >= 0) {
      final updatedMessages = [...state];
      updatedMessages[index] = message;
      state = updatedMessages;
    } else {
      state = [...state, message];
    }
  }
  
  Future<void> deleteMessagesForConversation(String conversationId) async {
    await _repository.deleteConversationMessages(conversationId);
    
    state = state.where((message) => message.conversationId != conversationId).toList();
  }
}

// Provider dla MessageNotifier
final messageNotifierProvider = StateNotifierProvider<MessageNotifier, List<Message>>((ref) {
  final repository = ref.watch(messageRepositoryProvider);
  return MessageNotifier(repository);
});
