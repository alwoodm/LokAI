import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lokai/ui/screens/home_screen.dart';
import 'package:lokai/ui/screens/chat_screen.dart';
import 'package:lokai/ui/screens/models_screen.dart';
import 'package:lokai/ui/screens/settings_screen.dart';

/// App router configuration
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  debugLogDiagnostics: true,
  routes: [
    // Shell route for screens with bottom navigation
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return ScaffoldWithNavBar(child: child);
      },
      routes: [
        // Home screen
        GoRoute(
          path: '/',
          name: 'home',
          pageBuilder: (context, state) => NoTransitionPage<void>(
            key: state.pageKey,
            child: const HomeScreen(),
          ),
        ),
        
        // Models screen
        GoRoute(
          path: '/models',
          name: 'models',
          pageBuilder: (context, state) => NoTransitionPage<void>(
            key: state.pageKey,
            child: const ModelsScreen(showBottomNav: false),
          ),
        ),
      ],
    ),
    
    // Chat screen with conversation ID parameter
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/chat/:id',
      name: 'chat',
      builder: (context, state) {
        final conversationId = state.pathParameters['id']!;
        return ChatScreen(conversationId: conversationId);
      },
    ),
    
    // Settings screen
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);

/// Scaffold with bottom navigation bar
class ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;

  const ScaffoldWithNavBar({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: location == '/' ? 0 : 1,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.go('/models');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.model_training),
            label: 'Models',
          ),
        ],
      ),
    );
  }
}
