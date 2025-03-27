import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokai/data/repositories/model_repository.dart';
import 'package:lokai/providers/model_provider.dart';
import 'package:lokai/services/model_manager.dart';

/// Provider for the ModelManager
final modelManagerProvider = Provider<ModelManager>((ref) {
  final repository = ref.watch(modelRepositoryProvider);
  return ModelManager(repository);
});

/// Provider for disk space information
final diskSpaceProvider = FutureProvider<DiskSpaceInfo>((ref) async {
  final modelManager = ref.watch(modelManagerProvider);
  final availableSpace = await modelManager.getAvailableDiskSpace();
  final usedModelSpace = await modelManager.getUsedModelSpace();
  
  return DiskSpaceInfo(
    availableSpace: availableSpace,
    usedModelSpace: usedModelSpace,
  );
});

/// Class to hold disk space information
class DiskSpaceInfo {
  final double availableSpace;
  final int usedModelSpace;
  
  DiskSpaceInfo({
    required this.availableSpace,
    required this.usedModelSpace,
  });
  
  String get formattedAvailableSpace {
    if (availableSpace < 1024) return '${availableSpace.toStringAsFixed(1)} B';
    if (availableSpace < 1024 * 1024) return '${(availableSpace / 1024).toStringAsFixed(1)} KB';
    if (availableSpace < 1024 * 1024 * 1024) return '${(availableSpace / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(availableSpace / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
  
  String get formattedUsedModelSpace {
    if (usedModelSpace < 1024) return '$usedModelSpace B';
    if (usedModelSpace < 1024 * 1024) return '${(usedModelSpace / 1024).toStringAsFixed(1)} KB';
    if (usedModelSpace < 1024 * 1024 * 1024) return '${(usedModelSpace / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(usedModelSpace / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
