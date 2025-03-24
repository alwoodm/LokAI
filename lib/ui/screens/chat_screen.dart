import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lokai/models/message.dart';
import 'package:lokai/providers/conversation_provider.dart';
import 'package:lokai/providers/message_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;
  
  const ChatScreen({super.key, required this.conversationId});
  
  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    // Załaduj wiadomości dla tej konwersacji
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(messageNotifierProvider.notifier).loadMessages(widget.conversationId);
    });
  }
  
  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    
    final messageNotifier = ref.read(messageNotifierProvider.notifier);
    final newMessage = Message(
      text: _messageController.text.trim(),
      isUser: true,
      conversationId: widget.conversationId,
    );
    
    messageNotifier.addMessage(newMessage);
    _messageController.clear();
    
    // Przewiń do najnowszej wiadomości
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
    
    // Symulacja odpowiedzi od AI (docelowo zintegrowana z rzeczywistym modelem)
    Future.delayed(const Duration(seconds: 1), () {
      final aiResponse = Message(
        text: 'To jest przykładowa odpowiedź od AI na twoje pytanie.',
        isUser: false,
        conversationId: widget.conversationId,
      );
      messageNotifier.addMessage(aiResponse);
      
      // Przewiń do najnowszej wiadomości
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final conversationAsync = ref.watch(conversationProvider(widget.conversationId));
    final messagesAsync = ref.watch(messageNotifierProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: conversationAsync.when(
          data: (conversation) => Text(conversation?.title ?? 'Konwersacja'),
          loading: () => const Text('Ładowanie...'),
          error: (_, __) => const Text('Błąd'),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              ref.read(conversationNotifierProvider.notifier).deleteConversation(widget.conversationId);
              context.go('/');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Lista wiadomości
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return const Center(
                    child: Text('Rozpocznij konwersację'),
                  );
                }
                
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  padding: const EdgeInsets.all(8.0),
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return Align(
                      alignment: message.isUser 
                          ? Alignment.centerRight 
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: message.isUser
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.secondary,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        child: Text(
                          message.text,
                          style: TextStyle(
                            color: message.isUser
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context).colorScheme.onSecondary,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Błąd: $error')),
            ),
          ),
          
          // Pasek wprowadzania wiadomości
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4.0,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Napisz wiadomość...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8.0),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  mini: true,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
