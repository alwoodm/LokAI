import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokai/data/repositories/message_repository.dart';
import 'package:lokai/models/message.dart';

// Provider dla repozytorium wiadomości
final messageRepositoryProvider = Provider<MessageRepository>((ref) {
  return MessageRepository();
});

// Provider dla wiadomości w danej konwersacji
final conversationMessagesProvider = FutureProvider.family<List<Message>, String>((ref, conversationId) async {
  final repository = ref.watch(messageRepositoryProvider);
  return repository.getConversationMessagesSorted(conversationId);
});

// Provider dla pojedynczej wiadomości
final messageProvider = FutureProvider.family<Message?, String>((ref, id) async {
  final repository = ref.watch(messageRepositoryProvider);
  return repository.getMessage(id);
});

// Provider dla ostatnich wiadomości w każdej konwersacji
final latestMessagesProvider = FutureProvider<Map<String, Message>>((ref) async {
  final repository = ref.watch(messageRepositoryProvider);
  return repository.getLatestMessages();
});

// Notifier dla zarządzania wiadomościami (CRUD)
class MessageNotifier extends StateNotifier<AsyncValue<List<Message>>> {
  final MessageRepository _repository;
  String? _currentConversationId;
  
  MessageNotifier(this._repository) : super(const AsyncValue.loading());
  
  Future<void> loadMessages(String conversationId) async {
    _currentConversationId = conversationId;
    state = const AsyncValue.loading();
    try {
      final messages = await _repository.getConversationMessagesSorted(conversationId);
      state = AsyncValue.data(messages);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  Future<String> addMessage(Message message) async {
    final id = await _repository.createMessage(message);
    if (_currentConversationId == message.conversationId) {
      loadMessages(message.conversationId); // Odświeżamy listę tylko jeśli dotyczy to aktualnej konwersacji
    }
    return id;
  }
  
  Future<void> deleteMessage(String id) async {
    await _repository.deleteMessage(id);
    if (_currentConversationId != null) {
      loadMessages(_currentConversationId!); // Odświeżamy listę
    }
  }
  
  Future<void> deleteConversationMessages(String conversationId) async {
    await _repository.deleteConversationMessages(conversationId);
    if (_currentConversationId == conversationId) {
      loadMessages(conversationId); // Odświeżamy listę
    }
  }
}

// Provider dla MessageNotifier
final messageNotifierProvider = StateNotifierProvider<MessageNotifier, AsyncValue<List<Message>>>((ref) {
  final repository = ref.watch(messageRepositoryProvider);
  return MessageNotifier(repository);
});
