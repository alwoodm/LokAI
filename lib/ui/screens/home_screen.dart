import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lokai/models/conversation.dart';
import 'package:lokai/models/message.dart';
import 'package:lokai/providers/conversation_provider.dart';
import 'package:lokai/providers/message_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(allConversationsProvider);
    final latestMessagesAsync = ref.watch(latestMessagesProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('LokAI'),
        backgroundColor: isDarkMode ? const Color(0xFF343541) : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: Container(
        color: isDarkMode ? const Color(0xFF343541) : const Color(0xFFF7F7F8),
        child: conversationsAsync.when(
          data: (conversations) {
            if (conversations.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No conversations yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () => _createNewConversation(context, ref),
                      icon: const Icon(Icons.add),
                      label: const Text('Start a new conversation'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            }
            
            return latestMessagesAsync.when(
              data: (latestMessages) => ListView.builder(
                itemCount: conversations.length,
                itemBuilder: (context, index) {
                  final conversation = conversations[index];
                  final lastMessage = latestMessages[conversation.id];
                  
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    elevation: 0,
                    color: isDarkMode ? const Color(0xFF3E3F4B) : Colors.white,
                    child: ListTile(
                      title: Text(
                        conversation.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      subtitle: lastMessage != null
                          ? Text(
                              lastMessage.text.length > 60
                                  ? '${lastMessage.text.substring(0, 60)}...'
                                  : lastMessage.text,
                              style: TextStyle(
                                color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                              ),
                            )
                          : Text(
                              'No messages',
                              style: TextStyle(
                                color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor.withAlpha(50),
                        child: Icon(
                          Icons.chat,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      trailing: Text(
                        _formatDate(conversation.updatedAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      onTap: () => context.go('/chat/${conversation.id}'),
                    ),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createNewConversation(context, ref),
        tooltip: 'New conversation',
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
  
  Future<void> _createNewConversation(BuildContext context, WidgetRef ref) async {
    try {
      final notifier = ref.read(conversationNotifierProvider.notifier);
      final newConversation = Conversation(title: 'New conversation');
      final id = await notifier.addConversation(newConversation);
      
      // Add a welcome message to the new conversation
      final messageNotifier = ref.read(messageNotifierProvider.notifier);
      final welcomeMessage = Message(
        text: 'Hello! How can I help you today?',
        isUser: false,
        conversationId: id,
      );
      await messageNotifier.addMessage(welcomeMessage);
      
      if (context.mounted) {
        context.go('/chat/$id');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating conversation: $e')),
        );
      }
    }
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return _getDayName(date.weekday);
    } else {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }
  
  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return '';
    }
  }
}
