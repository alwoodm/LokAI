import 'package:hive_flutter/hive_flutter.dart';
import '../ai_model.dart';
import '../conversation.dart';
import '../message.dart';

/// Klasa pomocnicza do rejestracji adapterów Hive
class HiveAdapters {
  /// Rejestruje wszystkie adaptery Hive
  static void registerAdapters() {
    // Adapter dla AIModel
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(AIModelAdapter());
    }
    
    // Adapter dla Conversation
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ConversationAdapter());
    }
    
    // Adapter dla Message
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(MessageAdapter());
    }
  }
}
