import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lokai/models/conversation.dart';
import 'package:lokai/providers/conversation_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(allConversationsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('LokAI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: conversationsAsync.when(
        data: (conversations) {
          if (conversations.isEmpty) {
            return const Center(
              child: Text('Nie masz jeszcze żadnych konwersacji'),
            );
          }
          
          return ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              return ListTile(
                title: Text(conversation.title),
                subtitle: Text('Ostatnia aktualizacja: ${conversation.updatedAt.toString().split('.')[0]}'),
                onTap: () => context.go('/chat/${conversation.id}'),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Błąd: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final notifier = ref.read(conversationNotifierProvider.notifier);
          final newConversation = Conversation(title: 'Nowa konwersacja');
          final id = await notifier.addConversation(newConversation);
          if (context.mounted) {
            context.go('/chat/$id');
          }
        },
        tooltip: 'Nowa konwersacja',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0: // Już jesteśmy na stronie głównej
              break;
            case 1:
              context.go('/models');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Główna',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.model_training),
            label: 'Modele',
          ),
        ],
      ),
    );
  }
}
