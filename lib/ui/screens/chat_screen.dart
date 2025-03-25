import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/conversation_service.dart';
import '../../models/message.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;

  const ChatScreen({
    super.key,
    required this.conversationId,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _initializeConversation();
  }

  Future<void> _initializeConversation() async {
    final conversationService = ref.read(conversationServiceProvider);
    
    // Aktywuj konwersację
    await conversationService.activateConversation(widget.conversationId);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _isGenerating = true;
    });

    final conversationService = ref.read(conversationServiceProvider);
    await conversationService.addUserMessage(_messageController.text);
    
    setState(() {
      _messageController.clear();
      // _isGenerating będzie ustawione na false, gdy odpowiedź będzie gotowa
    });
  }

  void _activateVoice() {
    // ignore: todo
    // TODO: Implement voice activation using speech_to_text package
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Voice activation not implemented yet')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Pobieramy aktywną konwersację
    final conversationAsync = ref.watch(activeConversationProvider);
    
    // Pobieramy wiadomości dla tej konwersacji
    final messagesAsync = ref.watch(activeConversationMessagesProvider(widget.conversationId));
    
    return Scaffold(
      appBar: AppBar(
        title: conversationAsync.when(
          data: (conversation) => Text(conversation?.title ?? 'New Conversation'),
          loading: () => const Text('Loading...'),
          error: (_, __) => const Text('Conversation'),
        ),
        elevation: 2,
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) => _buildMessageList(messages),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
          if (_isGenerating)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha(77), // 0.3 opacity converted to alpha (approx 77)
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.mic),
                  onPressed: _activateVoice,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(List<Message> messages) {
    // Jeśli nie ma wiadomości, wyświetl komunikat powitalny
    if (messages.isEmpty) {
      return const Center(
        child: Text('Start a conversation by sending a message'),
      );
    }

    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.all(8.0),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[messages.length - 1 - index];
        return MessageBubble(
          message: message.text,
          isUser: message.isUser,
          timestamp: message.timestamp,
        );
      },
    );
  }
}
