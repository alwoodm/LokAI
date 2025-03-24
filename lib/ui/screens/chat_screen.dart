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
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    // Load messages for this conversation
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
    
    // Scroll to the latest message
    _scrollToBottom();
    
    // AI response simulation
    setState(() {
      _isLoading = true;
    });
    
    // Simulate AI response delay
    Future.delayed(const Duration(seconds: 1), () {
      final aiResponse = Message(
        text: 'This is a sample response from the AI. I can help you with various tasks like writing, translation, data analysis, and more.',
        isUser: false,
        conversationId: widget.conversationId,
      );
      
      messageNotifier.addMessage(aiResponse);
      setState(() {
        _isLoading = false;
      });
      
      // Scroll to the latest message
      _scrollToBottom();
    });
  }
  
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final conversationAsync = ref.watch(conversationProvider(widget.conversationId));
    final messagesAsync = ref.watch(messageNotifierProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: conversationAsync.when(
          data: (conversation) => Text(conversation?.title ?? 'Conversation'),
          loading: () => const Text('Loading...'),
          error: (_, __) => const Text('Error'),
        ),
        backgroundColor: isDarkMode ? const Color(0xFF343541) : null,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go('/settings'),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _showDeleteConfirmation(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: Container(
              color: isDarkMode ? const Color(0xFF343541) : const Color(0xFFF7F7F8),
              child: messagesAsync.when(
                data: (messages) {
                  if (messages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Start a conversation',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: messages.length + (_isLoading ? 1 : 0),
                    padding: const EdgeInsets.all(0),
                    itemBuilder: (context, index) {
                      // Show loading indicator at the end of the list
                      if (_isLoading && index == messages.length) {
                        return _buildLoadingMessage();
                      }
                      
                      final message = messages[index];
                      return _buildMessageTile(message, isDarkMode);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
            ),
          ),
          
          // Message input bar
          Container(
            color: isDarkMode ? const Color(0xFF343541) : const Color(0xFFF7F7F8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF40414F) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: IconButton(
                      onPressed: _sendMessage,
                      icon: Icon(
                        Icons.send_rounded,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Conversation'),
        content: const Text('Are you sure you want to delete this conversation? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(conversationNotifierProvider.notifier).deleteConversation(widget.conversationId);
              context.go('/');
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMessageTile(Message message, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: message.isUser 
          ? (isDarkMode ? const Color(0xFF343541) : const Color(0xFFF7F7F8))
          : (isDarkMode ? const Color(0xFF444654) : Colors.white),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar for message
            CircleAvatar(
              backgroundColor: message.isUser 
                  ? Colors.deepPurple[100]
                  : Colors.deepPurple[400],
              child: Icon(
                message.isUser ? Icons.person : Icons.smart_toy,
                color: message.isUser ? Colors.deepPurple : Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            
            // Message content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.isUser ? 'You' : 'LokAI',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLoadingMessage() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: isDarkMode ? const Color(0xFF444654) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI avatar
            CircleAvatar(
              backgroundColor: Colors.deepPurple[400],
              child: const Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            
            // Loading indicator
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LokAI',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 30,
                  height: 20,
                  child: LinearProgressIndicator(
                    backgroundColor: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
