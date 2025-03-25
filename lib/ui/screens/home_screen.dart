import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/conversation_service.dart';
import '../../models/conversation.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(allConversationsProvider);
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            expandedHeight: 120.0,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('LokAI'),
              background: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => context.go('/settings'),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Recent Conversations',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          conversationsAsync.when(
            data: (conversations) => _buildConversationsList(context, ref, conversations),
            loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => SliverToBoxAdapter(
              child: Center(child: Text('Error: $error')),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Popular AI Models',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
                childAspectRatio: 1.5,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Card(
                    elevation: 2.0,
                    child: InkWell(
                      onTap: () => context.go('/models'),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.smart_toy,
                            size: 40,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 8.0),
                          Text('Model ${index + 1}'),
                        ],
                      ),
                    ),
                  );
                },
                childCount: 4, // Example count
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createNewConversation(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildConversationsList(BuildContext context, WidgetRef ref, List<Conversation> conversations) {
    if (conversations.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Text('No conversations yet. Start a new one!'),
          ),
        ),
      );
    }
    
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final conversation = conversations[index];
          return ListTile(
            title: Text(conversation.title),
            subtitle: Text(
              'Created ${_formatDate(conversation.createdAt)}',
            ),
            leading: CircleAvatar(
              child: Text('${index + 1}'),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteConversation(context, ref, conversation),
            ),
            onTap: () => context.go('/chat/${conversation.id}'),
          );
        },
        childCount: conversations.length,
      ),
    );
  }

  Future<void> _createNewConversation(BuildContext context, WidgetRef ref) async {
    final conversationService = ref.read(conversationServiceProvider);
    final conversation = await conversationService.createConversation('');
    
    if (context.mounted) {
      context.go('/chat/${conversation.id}');
    }
  }

  Future<void> _deleteConversation(BuildContext context, WidgetRef ref, Conversation conversation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Conversation'),
        content: Text('Are you sure you want to delete "${conversation.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      final conversationService = ref.read(conversationServiceProvider);
      await conversationService.deleteConversation(conversation.id);
      
      // Odśwież listę konwersacji
      ref.invalidate(allConversationsProvider);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
