import 'package:hive/hive.dart';
import 'package:lokai/models/conversation.dart';
import 'package:lokai/models/message.dart';
import 'package:lokai/models/ai_model.dart';
import 'package:lokai/models/user_settings.dart';

/// Class to register all Hive adapters
class HiveAdapters {
  /// Register all adapters
  static void registerAdapters() {
    Hive.registerAdapter(ConversationAdapter());
    Hive.registerAdapter(MessageAdapter());
    Hive.registerAdapter(AIModelAdapter());
    Hive.registerAdapter(UserSettingsAdapter());
    
    // Register adapters for complex types used in models
    Hive.registerAdapter(MapAdapter());
  }
}

/// Adapter for Map objects
class MapAdapter extends TypeAdapter<Map<String, dynamic>> {
  @override
  final int typeId = 10;
  
  @override
  Map<String, dynamic> read(BinaryReader reader) {
    final int length = reader.readInt();
    final Map<String, dynamic> map = {};
    for (var i = 0; i < length; i++) {
      final key = reader.read() as String;
      final value = reader.read();
      map[key] = value;
    }
    return map;
  }
  
  @override
  void write(BinaryWriter writer, Map<String, dynamic> obj) {
    writer.writeInt(obj.length);
    obj.forEach((key, value) {
      writer.write(key);
      writer.write(value);
    });
  }
}
