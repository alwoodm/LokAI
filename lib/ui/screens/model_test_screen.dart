import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokai/providers/model_manager_provider.dart';
import 'package:lokai/ui/widgets/model_download_card.dart';

/// A screen to test model downloading and management
class ModelTestScreen extends ConsumerWidget {
  const ModelTestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diskSpaceAsync = ref.watch(diskSpaceProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Model Downloads'),
        backgroundColor: isDarkMode ? const Color(0xFF343541) : null,
      ),
      body: Container(
        color: isDarkMode ? const Color(0xFF343541) : const Color(0xFFF7F7F8),
        child: Column(
          children: [
            // Disk space information
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF3E3F4B) : Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: diskSpaceAsync.when(
                data: (diskSpace) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available Space:',
                          style: TextStyle(
                            color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                          ),
                        ),
                        Text(
                          diskSpace.formattedAvailableSpace,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Used by Models:',
                          style: TextStyle(
                            color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                          ),
                        ),
                        Text(
                          diskSpace.formattedUsedModelSpace,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Text('Error: $error'),
              ),
            ),
            
            // Sample models to download
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(8),
                children: const [
                  // TinyLlama 1.1B (small model good for testing, ~600MB)
                  ModelDownloadCard(
                    url: 'https://huggingface.co/TinyLlama/TinyLlama-1.1B-Chat-v1.0/resolve/main/tokenizer.model?download=true',
                    name: 'TinyLlama Tokenizer',
                    description: 'TinyLlama 1.1B Tokenizer - A small and efficient tokenizer model for testing',
                    version: '1.0.0',
                    checksum: '9b8d00895e28f0bde5aeceed7cad159cd8e2c4a3199c423ef10b3a1d7fd96619',
                  ),
                  
                  // Another small test model (a BERT tokenizer, ~1MB)
                  ModelDownloadCard(
                    url: 'https://huggingface.co/google-bert/bert-base-uncased/resolve/main/vocab.txt?download=true',
                    name: 'BERT Vocabulary',
                    description: 'BERT Base Uncased Vocabulary - A small text file for testing',
                    version: '1.0.0',
                    checksum: '07eced375cec144d27c900241f3e339478dec958f92fddbc551f295c992038a3',
                  ),
                  
                  // A small test image (~40KB)
                  ModelDownloadCard(
                    url: 'https://github.com/flutter/website/blob/main/src/assets/images/flutter-lockup.png?raw=true',
                    name: 'Test Image',
                    description: 'A small test image to verify download and checksum verification',
                    version: '1.0.0',
                    checksum: '5b91ee5d6dbb6aec12a28a2e01493b1ae9525381b1962a21b8e6e96d6674fa01',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
