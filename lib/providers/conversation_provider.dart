import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokai/data/repositories/conversation_repository.dart';
import 'package:lokai/models/conversation.dart';

// Provider dla repozytorium konwersacji
final conversationRepositoryProvider = Provider<ConversationRepository>((ref) {
  return ConversationRepository();
});

// Provider dla wszystkich konwersacji
final allConversationsProvider = FutureProvider<List<Conversation>>((ref) async {
  final repository = ref.watch(conversationRepositoryProvider);
  return repository.getAllConversations();
});

// Provider dla ostatnich konwersacji
final recentConversationsProvider = FutureProvider<List<Conversation>>((ref) async {
  final repository = ref.watch(conversationRepositoryProvider);
  return repository.getRecentConversations();
});

// Provider dla pojedynczej konwersacji
final conversationProvider = FutureProvider.family<Conversation?, String>((ref, id) async {
  final repository = ref.watch(conversationRepositoryProvider);
  return repository.getConversation(id);
});

// Notifier dla zarządzania konwersacjami (CRUD)
class ConversationNotifier extends StateNotifier<AsyncValue<List<Conversation>>> {
  final ConversationRepository _repository;
  
  ConversationNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadConversations();
  }
  
  Future<void> loadConversations() async {
    state = const AsyncValue.loading();
    try {
      final conversations = await _repository.getAllConversations();
      state = AsyncValue.data(conversations);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  Future<String> addConversation(Conversation conversation) async {
    final id = await _repository.createConversation(conversation);
    loadConversations(); // Odświeżamy listę
    return id;
  }
  
  Future<void> updateConversation(Conversation conversation) async {
    await _repository.updateConversation(conversation);
    loadConversations(); // Odświeżamy listę
  }
  
  Future<void> deleteConversation(String id) async {
    await _repository.deleteConversation(id);
    loadConversations(); // Odświeżamy listę
  }
  
  Future<void> deleteAllConversations() async {
    await _repository.deleteAllConversations();
    loadConversations(); // Odświeżamy listę
  }
}

// Provider dla ConversationNotifier
final conversationNotifierProvider = StateNotifierProvider<ConversationNotifier, AsyncValue<List<Conversation>>>((ref) {
  final repository = ref.watch(conversationRepositoryProvider);
  return ConversationNotifier(repository);
});
