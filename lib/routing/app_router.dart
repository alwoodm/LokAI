import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lokai/ui/screens/home_screen.dart';
import 'package:lokai/ui/screens/chat_screen.dart';
import 'package:lokai/ui/screens/models_screen.dart';
import 'package:lokai/ui/screens/settings_screen.dart';

/// Konfiguracja nawigacji dla aplikacji
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Ekran główny
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    
    // Ekran czatu z ID konwersacji jako parametrem
    GoRoute(
      path: '/chat/:id',
      name: 'chat',
      builder: (context, state) {
        final conversationId = state.pathParameters['id']!;
        return ChatScreen(conversationId: conversationId);
      },
    ),
    
    // Ekran biblioteki modeli
    GoRoute(
      path: '/models',
      name: 'models',
      builder: (context, state) => const ModelsScreen(),
    ),
    
    // Ekran ustawień
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
