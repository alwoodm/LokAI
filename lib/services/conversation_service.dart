import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ai/simple_tokenizer.dart';
import '../ai/tflite_service.dart';
import '../data/repositories/conversation_repository.dart';
import '../data/repositories/message_repository.dart';
import '../models/ai_model.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../providers/model_provider.dart';

/// Serwis do zarządzania konwersacjami
class ConversationService {
  final ConversationRepository _conversationRepository;
  final MessageRepository _messageRepository;
  final TFLiteService _tfliteService;
  final Ref _ref;
  
  // Limity dla kontekstu konwersacji
  static const int _maxTokensInContext = 2048; // Typowy limit kontekstu dla mniejszych modeli
  static const int _maxMessagesInContext = 20; // Maksymalna liczba wiadomości w kontekście
  
  // Aktywna konwersacja i jej kontekst
  String? _activeConversationId;
  List<Message> _contextMessages = [];
  int _contextTokenCount = 0;
  AIModel? _activeModel;
  
  ConversationService(this._ref) :
    _conversationRepository = ConversationRepository(),
    _messageRepository = MessageRepository(),
    _tfliteService = TFLiteService();
  
  /// Inicjalizuje serwis
  Future<void> initialize() async {
    await _conversationRepository.initialize();
    await _messageRepository.initialize();
    await _tfliteService.initialize();
  }
  
  /// Tworzy nową konwersację
  Future<Conversation> createConversation(String initialMessage, {String? modelId}) async {
    // Pobierz aktywny model z provider'a jeśli nie podano modelId
    final model = modelId != null 
        ? _ref.read(allModelsProvider).firstWhere((m) => m.id == modelId, orElse: () => _getDefaultModel())
        : _ref.read(activeModelProvider) ?? _getDefaultModel();
    
    // Utwórz konwersację
    final conversation = Conversation(
      title: 'New Conversation',
      modelId: model.id,
    );
    
    await _conversationRepository.saveConversation(conversation);
    
    // Ustaw jako aktywną
    await activateConversation(conversation.id);
    
    // Dodaj pierwszą wiadomość użytkownika
    if (initialMessage.isNotEmpty) {
      await addUserMessage(initialMessage);
      
      // Wygeneruj tytuł na podstawie pierwszej wiadomości
      conversation.generateTitle(initialMessage);
      await _conversationRepository.saveConversation(conversation);
    }
    
    return conversation;
  }
  
  /// Aktywuje konwersację
  Future<bool> activateConversation(String conversationId) async {
    try {
      final conversation = await _conversationRepository.getConversation(conversationId);
      if (conversation == null) {
        return false;
      }
      
      _activeConversationId = conversationId;
      
      // Załaduj model
      final model = _ref.read(allModelsProvider)
          .firstWhere((m) => m.id == conversation.modelId, orElse: () => _getDefaultModel());
      _activeModel = model;
      
      // Załaduj wiadomości do kontekstu
      await _loadContextMessages(conversationId);
      
      return true;
    } catch (e) {
      debugPrint('Error activating conversation: $e');
      return false;
    }
  }
  
  /// Pobiera aktywną konwersację
  Future<Conversation?> getActiveConversation() async {
    if (_activeConversationId == null) {
      return null;
    }
    
    return await _conversationRepository.getConversation(_activeConversationId!);
  }
  
  /// Ładuje wiadomości kontekstowe dla konwersacji
  Future<void> _loadContextMessages(String conversationId) async {
    final conversation = await _conversationRepository.getConversation(conversationId);
    if (conversation == null) {
      _contextMessages = [];
      _contextTokenCount = 0;
      return;
    }
    
    // Pobierz wiadomości dla konwersacji
    final allMessages = await _messageRepository.getMessagesForConversation(conversationId);
    
    // Wykorzystaj tylko ostatnie n wiadomości jako kontekst
    if (allMessages.length > _maxMessagesInContext) {
      _contextMessages = allMessages.skip(allMessages.length - _maxMessagesInContext).toList();
    } else {
      _contextMessages = allMessages;
    }
    
    // Policz tokeny w kontekście
    _contextTokenCount = _contextMessages.fold(0, (sum, message) => sum + message.tokenCount);
  }
  
  /// Dodaje wiadomość użytkownika i generuje odpowiedź
  Future<Message?> addUserMessage(String text) async {
    if (_activeConversationId == null) {
      return null;
    }
    
    try {
      // Tworzenie wiadomości użytkownika
      final tokenCount = SimpleTokenizer.countTokens(text);
      final message = Message(
        text: text,
        isUser: true,
        conversationId: _activeConversationId!,
        tokenCount: tokenCount,
      );
      
      // Zapisz wiadomość użytkownika
      await _messageRepository.saveMessage(message);
      
      // Dodaj ID wiadomości do konwersacji
      final conversation = await _conversationRepository.getConversation(_activeConversationId!);
      if (conversation != null) {
        conversation.addMessageId(message.id);
        conversation.tokenCount += tokenCount;
        await _conversationRepository.saveConversation(conversation);
      }
      
      // Aktualizuj kontekst
      _contextMessages.add(message);
      _contextTokenCount += tokenCount;
      
      // Generuj odpowiedź asynchronicznie
      _generateAIResponse();
      
      return message;
    } catch (e) {
      debugPrint('Error adding user message: $e');
      return null;
    }
  }
  
  /// Generuje odpowiedź AI na podstawie kontekstu konwersacji
  Future<void> _generateAIResponse() async {
    if (_activeConversationId == null || _contextMessages.isEmpty || _activeModel == null) {
      return;
    }
    
    try {
      // Przygotuj kontekst dla modelu AI
      final context = _prepareContext();
      
      // Symulujemy generowanie odpowiedzi (w rzeczywistości użylibyśmy modelu)
      final aiResponse = await _simulateAIResponse(context);
      
      // Tworzenie wiadomości AI
      final tokenCount = SimpleTokenizer.countTokens(aiResponse);
      final message = Message(
        text: aiResponse,
        isUser: false,
        conversationId: _activeConversationId!,
        tokenCount: tokenCount,
      );
      
      // Zapisz wiadomość AI
      await _messageRepository.saveMessage(message);
      
      // Dodaj ID wiadomości do konwersacji
      final conversation = await _conversationRepository.getConversation(_activeConversationId!);
      if (conversation != null) {
        conversation.addMessageId(message.id);
        conversation.tokenCount += tokenCount;
        await _conversationRepository.saveConversation(conversation);
      }
      
      // Aktualizuj kontekst
      _contextMessages.add(message);
      _contextTokenCount += tokenCount;
      
      // Przytnij kontekst jeśli przekracza limit
      await _pruneContextIfNeeded();
    } catch (e) {
      debugPrint('Error generating AI response: $e');
      
      // W przypadku błędu, dodaj informacyjną wiadomość
      final errorMessage = Message(
        text: 'Sorry, I encountered an error while processing your request.',
        isUser: false,
        conversationId: _activeConversationId!,
      );
      
      await _messageRepository.saveMessage(errorMessage);
      
      final conversation = await _conversationRepository.getConversation(_activeConversationId!);
      if (conversation != null) {
        conversation.addMessageId(errorMessage.id);
        await _conversationRepository.saveConversation(conversation);
      }
      
      _contextMessages.add(errorMessage);
    }
  }
  
  /// Przygotowuje kontekst dla modelu AI
  String _prepareContext() {
    final buffer = StringBuffer();
    
    for (final message in _contextMessages) {
      buffer.writeln(message.isUser ? 'User: ${message.text}' : 'AI: ${message.text}');
    }
    
    return buffer.toString();
  }
  
  /// Usuwa starsze wiadomości z kontekstu, jeśli przekracza limit
  Future<void> _pruneContextIfNeeded() async {
    if (_contextTokenCount <= _maxTokensInContext && _contextMessages.length <= _maxMessagesInContext) {
      return;
    }
    
    // Usuń najstarsze wiadomości, aż osiągniesz limit
    while (_contextTokenCount > _maxTokensInContext || _contextMessages.length > _maxMessagesInContext) {
      if (_contextMessages.isEmpty) break;
      
      final oldestMessage = _contextMessages.removeAt(0);
      _contextTokenCount -= oldestMessage.tokenCount;
    }
  }
  
  /// Symuluje odpowiedź AI (w rzeczywistym środowisku użylibyśmy modelu)
  Future<String> _simulateAIResponse(String context) async {
    // Tutaj należałoby wykorzystać TFLiteService do wygenerowania odpowiedzi
    // Dla uproszczenia symulujemy odpowiedź
    
    // Symulacja opóźnienia przetwarzania
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Pobierz ostatnią wiadomość użytkownika
    final lastUserMessage = _contextMessages.lastWhere((m) => m.isUser);
    
    // Prosta logika generowania odpowiedzi
    if (lastUserMessage.text.toLowerCase().contains('hello') || 
        lastUserMessage.text.toLowerCase().contains('hi')) {
      return 'Hello! How can I assist you today?';
    } else if (lastUserMessage.text.toLowerCase().contains('help')) {
      return 'I\'m here to help! What would you like to know?';
    } else if (lastUserMessage.text.toLowerCase().contains('thank')) {
      return 'You\'re welcome! Is there anything else you\'d like to know?';
    } else if (lastUserMessage.text.contains('?')) {
      return 'That\'s an interesting question. Let me think... Based on my knowledge, I would say it depends on the specific context.';
    } else {
      return 'I understand what you\'re saying about "${lastUserMessage.text}". Would you like to know more about this topic?';
    }
    
    // W rzeczywistej implementacji użylibyśmy modelu:
    /*
    try {
      if (_activeModel == null) return "No active model to generate response.";
      
      final interpreter = await _tfliteService.loadAIModel(_activeModel!);
      
      // Przygotowanie danych wejściowych (zależne od modelu)
      final inputTensors = _tfliteService.getInputTensors(interpreter);
      final input = <Object>[];
      
      // Tutaj należy przekształcić tekst kontekstu do formatu wymaganego przez model
      
      // Przygotowanie bufora na wynik
      final outputTensors = _tfliteService.getOutputTensors(interpreter);
      final outputs = <int, Object>{};
      
      // Uruchomienie inferencji
      await _tfliteService.runInference(interpreter, input, outputs);
      
      // Przetworzenie wyników na tekst
      // Kod zależny od formatu wyjściowego modelu
      
      return "Response generated by AI";
    } catch (e) {
      debugPrint('Error using AI model: $e');
      return "Sorry, I encountered a problem generating a response.";
    }
    */
  }
  
  /// Zwraca domyślny model, gdy nie znaleziono aktywnego
  AIModel _getDefaultModel() {
    // Domyślny model, używany gdy nie ma innych
    return AIModel(
      name: 'Default Model',
      description: 'Basic conversation model',
      size: 0,
      filePath: '',
      version: '1.0.0',
    );
  }
  
  /// Pobiera wszystkie konwersacje
  Future<List<Conversation>> getAllConversations() async {
    return await _conversationRepository.getAllConversations();
  }
  
  /// Pobiera konwersację po ID
  Future<Conversation?> getConversation(String id) async {
    return await _conversationRepository.getConversation(id);
  }
  
  /// Pobiera wiadomości dla konwersacji
  Future<List<Message>> getMessagesForConversation(String conversationId) async {
    return await _messageRepository.getMessagesForConversation(conversationId);
  }
  
  /// Usuwa konwersację i wszystkie jej wiadomości
  Future<void> deleteConversation(String id) async {
    await _messageRepository.deleteAllMessagesForConversation(id);
    await _conversationRepository.deleteConversation(id);
    
    if (_activeConversationId == id) {
      _activeConversationId = null;
      _contextMessages = [];
      _contextTokenCount = 0;
    }
  }
  
  /// Zamyka repozytoria
  Future<void> dispose() async {
    await _conversationRepository.close();
    await _messageRepository.close();
  }
}

/// Provider dla ConversationService
final conversationServiceProvider = Provider<ConversationService>((ref) {
  return ConversationService(ref);
});

/// Provider dla aktywnej konwersacji
final activeConversationProvider = FutureProvider<Conversation?>((ref) async {
  final service = ref.watch(conversationServiceProvider);
  return await service.getActiveConversation();
});

/// Provider dla listy wszystkich konwersacji
final allConversationsProvider = FutureProvider<List<Conversation>>((ref) async {
  final service = ref.watch(conversationServiceProvider);
  return await service.getAllConversations();
});

/// Provider dla wiadomości aktywnej konwersacji
final activeConversationMessagesProvider = FutureProvider.family<List<Message>, String>((ref, conversationId) async {
  final service = ref.watch(conversationServiceProvider);
  return await service.getMessagesForConversation(conversationId);
});
