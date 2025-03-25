import 'package:flutter/material.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;

  const ChatScreen({
    super.key,
    required this.conversationId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    // Here you would load existing messages from the repository
    // For now, we'll add some dummy messages
    _messages.add({
      'text': 'Hello! How can I help you today?',
      'isUser': false,
      'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = {
      'text': _messageController.text,
      'isUser': true,
      'timestamp': DateTime.now(),
    };

    setState(() {
      _messages.add(userMessage);
      _messageController.clear();
      _isGenerating = true;
    });

    // Simulate AI response (would actually call the AI service)
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _messages.add({
          'text': 'I received your message: "${userMessage['text']}"',
          'isUser': false,
          'timestamp': DateTime.now(),
        });
        _isGenerating = false;
      });
    }
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Conversation ${widget.conversationId}'),
        elevation: 2,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                return MessageBubble(
                  message: message['text'],
                  isUser: message['isUser'],
                  timestamp: message['timestamp'],
                );
              },
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
}
