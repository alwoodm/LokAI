import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../ui/screens/home_screen.dart';
import '../ui/screens/chat_screen.dart';
import '../ui/screens/models_screen.dart';
import '../ui/screens/settings_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/chat/:id',
        name: 'chat',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return ChatScreen(conversationId: id);
        },
      ),
      GoRoute(
        path: '/models',
        name: 'models',
        builder: (context, state) => const ModelsScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Route not found: ${state.uri}'),
      ),
    ),
  );
}
