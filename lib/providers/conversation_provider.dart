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

// Notifier dla operacji na konwersacjach
class ConversationNotifier extends StateNotifier<List<Conversation>> {
  final ConversationRepository _repository;

  ConversationNotifier(this._repository) : super([]);

  Future<void> loadConversations() async {
    final conversations = await _repository.getAllConversations();
    state = conversations;
  }

  Future<Conversation> createNewConversation(String title, String modelId) async {
    final conversation = Conversation(
      title: title,
      modelId: modelId,
    );
    
    final createdConversation = await _repository.createConversation(conversation);
    state = [...state, createdConversation];
    return createdConversation;
  }

  Future<void> updateConversation(Conversation conversation) async {
    await _repository.updateConversation(conversation);
    
    state = state.map((c) => c.id == conversation.id ? conversation : c).toList();
  }

  Future<void> deleteConversation(String id) async {
    await _repository.deleteConversation(id);
    
    state = state.where((conversation) => conversation.id != id).toList();
  }

  Future<void> deleteAllConversations() async {
    await _repository.deleteAllConversations();
    
    state = [];
  }
}

// Provider dla ConversationNotifier
final conversationNotifierProvider = StateNotifierProvider<ConversationNotifier, List<Conversation>>((ref) {
  final repository = ref.watch(conversationRepositoryProvider);
  return ConversationNotifier(repository);
});
