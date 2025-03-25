import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                // This would normally come from a repository
                return ListTile(
                  title: Text('Conversation ${index + 1}'),
                  subtitle: Text('Last message from conversation ${index + 1}'),
                  leading: CircleAvatar(
                    child: Text('${index + 1}'),
                  ),
                  onTap: () => context.go('/chat/$index'),
                );
              },
              childCount: 10, // Example count
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
        onPressed: () {
          // Create a new conversation and navigate to it
          final newId = DateTime.now().millisecondsSinceEpoch.toString();
          context.go('/chat/$newId');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
